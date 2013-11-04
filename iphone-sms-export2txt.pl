#!/usr/bin/perl

use strict;
use warnings;

use DBI;

use File::Spec qw();
use File::Find;
use Fcntl qw(:DEFAULT :flock);

# manually set the backup path
# and the output file will be on the desktop
# usage: perl iphone-sms-export2txt.pl [/path/to/itunes/backup]
my $backup_path = shift;
my $log_file = File::Spec->catfile($ENV{HOME}, 'Desktop', 'sms-export.txt');

if ( not defined $backup_path ) {
    if ( $^O =~ /ms/i or $^O eq 'cygwin' ) {
        $backup_path = File::Spec->catdir(
            $ENV{'HOME'}, 'AppData', 'Roaming','Apple Computer', 'MobileSync', 'Backup'
        );
    } elsif ( $^O =~ /darwin/i ) {
        $backup_path = File::Spec->catdir(
            $ENV{'HOME'}, 'Library', 'Application Support', 'MobileSync', 'Backup'
        );
    } else {
        $backup_path = File::Spec->catdir(
            $ENV{'HOME'}, 'AppData', 'Roaming','Apple Computer', 'MobileSync', 'Backup'
        );
    }
}

### $backup_path
find( \&wanted, $backup_path);

sub wanted {
    # judge file is sqlite or not
    # 0 is and 1 is not
    return if file_is_sqlite($File::Find::name);

    my $message = get_sms_message( $File::Find::name );
    write_message_to_file($message, $log_file);
}

sub file_is_sqlite {
    my $file = shift;

    # win seems can't open dir
    # and will give permission denied
    return 1 if -d $file;

    sysopen my $fh, $file, O_RDONLY
        or die "can't open $file: $!";

    my $data;
    my $length = 20;
    sysread $fh, $data, 20;
    my $flag = 1;
    if ( $data =~ /sqlite/i ) {
        $flag = 0;
    }

    return $flag;
}

sub get_sms_message {
    my $dbfile = shift;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");

    my $sql = qq{select chat.guid, message.text from chat, message where chat.account_id=message.account_guid order by message.date;};

    my $data;
    eval {
        $data = $dbh->selectall_arrayref($sql);
    };

    $dbh->disconnect();
    return $data;
}

sub write_message_to_file {
    my ($msg, $file) = @_;

    open my $fh, '>>', $file
        or die "Can't open $file: $!";
    for my $line ( @$msg ) {
        my ($from, $text) = @$line;
        $from =~ s/[^\d]//g;
        print $fh join "\t", $from, $text;
        print $fh "\n";
    }

    close $fh;
}

