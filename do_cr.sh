_expect ()
{
        host=$1
        PWD=$2

	set timeout 600
	
        /usr/bin/expect <<EOD
        spawn ssh $USER@$host
	

	set timeout 600	
	log_file ~/expectoutput/$host.expect.log ;# Logging all expect output to a file ~/expectout/hostname.expect.log
        
	expect {
		"(yes/no)? " {
			send "yes\r" 
		} "$USER@$host" { 
			send ""
		}	
	}	
	expect "password: " { send "$PWD\r" }

        expect -exact "~]$ "
                send "sudo -v\r"

        expect "$USER: "
                send "$PWD\r"
	expect -exact "$ "
                send "sudo -b /etc/init.d/ruby193-mcollective restart \r"
	expect -exact "$ "
		send "sudo -k \r"

	expect {
    		" $" {
        		# ...
    		}
    		-re {^([^\r]*)\r\n} {
        	exp_continue
    		}
	}
EOD
}
_scpthefiles_send()
{
        host=$1
        PWD=$2
        file=($3 $4 $5 $6)
        /usr/bin/expect <<EOD

        spawn scp -rp ${file[@]} $USER@$host:~/.
        
	log_file ~/expectoutput/$host.expect.log ;# Logging all expect output to a file ~/expectout/hostname.expect.log
	expect {
                "(yes/no)? " {
                        send "yes\r"
                } "$USER@$host" {
                        send ""
                }
        }

	expect -exact "password: "
		send "$PWD\r"
	
	expect {
                " $" {
                        # ...
                }
                -re {^([^\r]*)\r\n} {
                exp_continue
                }
        }

EOD

}
_scpthefiles_recieve()
{
	host=$1
        PWD=$2
        file=$3
        /usr/bin/expect <<EOD

        spawn scp -rp -q $USER@$host:~/$3 . 

        log_file ~/expectoutput/$host.expect.log ;# Logging all expect output to a file ~/expectout/hostname.expect.log
        expect {
                "(yes/no)? " {
                        send "yes\r"
                } "$USER@$host" {
                        send ""
                }
        }

        expect -exact "password: "
                send "$PWD\r"

        expect {
                " $" {
                        # ...
                }
                -re {^([^\r]*)\r\n} {
                exp_continue
                }
        }

EOD
}
_read_hostname_and_do_expect_magic ()
{
        hostnamefile=$1
        PWD=$2
        while read hostname
        do
                if [ -n "$hostname" ];
                then
 
			#_scpthefiles_send $hostname $PWD check_mcollective.php deploy_check_mcollective.sh cron.helper.php 
                        
			_expect $hostname $PWD 

		#	_scpthefiles_recieve $hostname $PWD status.$hostname &
                fi





	#		echo "$hostname,`cat gearstemp.txt.$hostname | sed -e 'H;${x;s/\n/ /g;s/^,//;p;};d'`,`cat gearstemp.txt | wc -l`" >> Hostcapacity.csv
		
        done < $hostnamefile
}
######Main - The Real Deal
read -s PWD
hostnamefile=$1
if [ -f  $hostnamefile ]
then
        _read_hostname_and_do_expect_magic $hostnamefile $PWD

else
        echo "Please Enter the configuration file with all hostname!"
fi
