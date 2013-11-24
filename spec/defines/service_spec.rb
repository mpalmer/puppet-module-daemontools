require 'spec_helper'

describe "daemontools::service" do
	let(:title) { "rspecsvc" }
	let(:facts) { { :operatingsystem => 'Debian' } }
	
	context "no options" do
		it "bombs out" do
			expect { should contain_file('/error') }.
			  to raise_error(Puppet::Error,
			       /Must pass command to Daemontools::Service\[rspecsvc\]/
			     )
		end
	end

	context "just a command" do
		let(:params) { { :command => "/bin/true" } }
		
		it "bombs out" do
			expect { should contain_file('/error') }.
			  to raise_error(Puppet::Error,
			       /Must pass user to Daemontools::Service\[rspecsvc\]/
			     )
		end
	end
	
	context "basic command/user combo" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred"
		             } }
		
		it { should contain_class("daemontools::base") }
		
		it do
			should contain_file("/var/lib/service/rspecsvc/run").
			       with_content(%r{^cd /var/lib/service/rspecsvc }).
		          with_content(%r{^exec setuidgid fred /bin/true$})
		end
		
		it do
			should contain_file("/etc/service/rspecsvc").
			       with_ensure("/var/lib/service/rspecsvc")
		end
		
		it do
			should contain_daemontools__service("rspecsvc/log").
			       with_command(%r{/usr/bin/multilog })
		end
		
		it do
			should contain_exec("daemontools/service/restart:rspecsvc").
			       with_command("/usr/bin/svc -t '/var/lib/service/rspecsvc'")
		end
		
		it do
			should contain_file("/var/lib/service/rspecsvc/down").
			       with_ensure("absent")
		end
	end
	
	context "when 'ensure => running'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :ensure  => "running"
		             } }
		
		it do
			should contain_exec("daemontools/service/restart:rspecsvc").
			       with_command("/usr/bin/svc -t '/var/lib/service/rspecsvc'")
		end
		
		it do
			should contain_exec("daemontools/service/running:rspecsvc").
			       with_command("/usr/bin/svc -u '/var/lib/service/rspecsvc'")
		end
		
		it do
			should_not contain_exec("daemontools/service/stopped:rspecsvc")
		end
	end

	context "when 'ensure => stopped'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :ensure  => "stopped"
		             } }
		
		it do
			should contain_exec("daemontools/service/stopped:rspecsvc").
			       with_command("/usr/bin/svc -d '/var/lib/service/rspecsvc'")
		end

		it do
			should_not contain_exec("daemontools/service/running:rspecsvc")
		end

		it do
			should_not contain_exec("daemontools/service/restart:rspecsvc")
		end
	end

	context "when 'ensure => absent'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :ensure  => "absent"
		             } }
		
		it do
			should contain_exec("daemontools/service/absent:rspecsvc").
			       with_command("/usr/local/sbin/purge_daemontools_service 'rspecsvc'").
			       with_onlyif("/usr/bin/test -e '/var/lib/service/rspecsvc'")
		end
		
		it do
			should_not contain_file("/etc/service/rspecsvc")
		end
		
		it do
			should_not contain_file("/var/lib/service/rspecsvc")
		end

		it do
			should_not contain_exec("daemontools/service/restart:rspecsvc")
		end
	end
	
	context "when providing an invalid username" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "Michael Jackson"
		             } }
		
		it do
			expect { should contain_file('/error') }.
			       to raise_error(Puppet::Error, /Invalid value for user: /)
		end
	end
	
	context "when 'setuid => false'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :setuid  => false
		             } }
		
		it do
			should contain_file("/var/lib/service/rspecsvc/run").
			       with_content(%r{^exec envuidgid fred /bin/true$})
		end
		
		context "when 'use_secondary_groups => true'" do
			let(:params) { { :command              => "/bin/true",
			                 :user                 => "fred",
			                 :setuid               => false,
			                 :use_secondary_groups => true
			             } }
			
			it do
				expect { should contain_file('/error') }.
				       to raise_error(Puppet::Error, /Cannot use use_secondary_groups without setuid/)
			end
		end
	end
	
	context "when 'use_secondary_groups => true'" do
		let(:params) { { :command              => "/bin/true",
		                 :user                 => "fred",
		                 :use_secondary_groups => true
		             } }
		
		it do
			should contain_file("/var/lib/service/rspecsvc/run").
			       with_content(%r{^exec su fred /bin/true$})
		end
	end
	
	context "with custom directory" do
		let(:params) { { :command   => "/bin/true",
		                 :user      => "fred",
		                 :directory => "/sleepy/hollow"
		             } }
		
		it do
			should contain_file("/var/lib/service/rspecsvc/run").
			       with_content(%r{^cd /sleepy/hollow })
		end
	end
	
	context "with invalid directory" do
		let(:params) { { :command   => "/bin/true",
		                 :user      => "fred",
		                 :directory => "../../../etc/passwd"
		             } }
		
		it do
			expect { should contain_file('/error') }.
			       to raise_error(Puppet::Error, /directory must be an absolute path/)
		end
	end
	
	context "when 'sudo_control => true'" do
		let(:params) { { :command      => "/bin/true",
		                 :user         => "fred",
		                 :sudo_control => true
		             } }
		
		it do
			should contain_daemontools__sudo("fred/rspecsvc").
			       with_service("/etc/service/rspecsvc").
			       with_user("fred").
			       with_passwd(false)
		end
	end
	
	context "when 'sudo_control => daemontools'" do
		let(:params) { { :command      => "/bin/true",
		                 :user         => "fred",
		                 :sudo_control => "daemontools"
		             } }
		
		it do
			should contain_daemontools__sudo("fred/rspecsvc").
			       with_service("/etc/service/rspecsvc").
			       with_user("fred").
			       with_passwd(false)
		end
	end
	
	context "when 'sudo_control => allah'" do
		let(:params) { { :command      => "/bin/true",
		                 :user         => "fred",
		                 :sudo_control => "allah"
		             } }
		
		it do
			should contain_allah__sudo("fred/rspecsvc").
			       with_service("rspecsvc").
			       with_user("fred").
			       with_passwd(false)
		end
	end
	
	context "when 'sudo_control => both'" do
		let(:params) { { :command      => "/bin/true",
		                 :user         => "fred",
		                 :sudo_control => "both"
		             } }
		
		it do
			should contain_allah__sudo("fred/rspecsvc").
			       with_service("rspecsvc").
			       with_user("fred").
			       with_passwd(false)
		end

		it do
			should contain_daemontools__sudo("fred/rspecsvc").
			       with_service("/etc/service/rspecsvc").
			       with_user("fred").
			       with_passwd(false)
		end
	end
	
	context "when 'sudo_control => gibberish'" do
		let(:params) { { :command      => "/bin/true",
		                 :user         => "fred",
		                 :sudo_control => "gibberish"
		             } }
		
		it do
			expect { should contain_file('/error') }.
			       to raise_error(Puppet::Error, /Invalid value for sudo_control: gibberish/)
		end
	end
	
	context "when 'sudo_user => bob'" do
		context "when 'sudo_control => daemontools'" do
			let(:params) { { :command      => "/bin/true",
								  :user         => "fred",
								  :sudo_control => "daemontools",
								  :sudo_user    => "bob"
								} }
			
			it do
				should contain_daemontools__sudo("bob/rspecsvc").
				       with_service("/etc/service/rspecsvc").
				       with_user("bob").
				       with_passwd(false)
			end
		end

		context "when 'sudo_control => allah'" do
			let(:params) { { :command      => "/bin/true",
								  :user         => "fred",
								  :sudo_control => "allah",
								  :sudo_user    => "bob"
								} }
			
			it do
				should contain_allah__sudo("bob/rspecsvc").
				       with_service("rspecsvc").
				       with_user("bob").
				       with_passwd(false)
			end
		end
	end
	
	context "when 'log => false'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :log     => false
		             } }
		
		it do
			should_not contain_daemontools__service('rspecsvc/log')
		end
	end
	
	context "when 'log => /usr/sbin/awesant'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :log     => "/usr/sbin/awesant"
		             } }
		
		it do
			should contain_daemontools__service('rspecsvc/log').
			       with_command("/usr/sbin/awesant").
			       with_user("fred").
			       with_log(false)
		end
	end
	
	context "when 'environment => {something}'" do
		let(:params) { { :command     => "/bin/true",
		                 :user        => "fred",
		                 :environment => {
		                    "FOO"    => "bar",
		                    "BAZ"    => "wombat",
		                    "DIRTY"  => "\"pool\", that's what this is",
		                    "RANSOM" => "$1,000,000"
		             } } }
		
		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(/^export FOO='bar'$/)
		end

		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(/^export BAZ='wombat'$/)
		end

		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(/^export DIRTY='"pool", that'\\''s what this is'$/)
		end

		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(/^export RANSOM='\$1,000,000'$/)
		end
	end
	
	{
	 "data_segment"     => "-d",
	 "stack_segment"    => "-s",
	 "file_descriptors" => "-n",
	 "processes"        => "-u",
	 "file_size"        => "-f",
	 "core_size"        => "-c",
	 "rss"              => "-m",
	 "cpu_time"         => "-t",
	 "virtual_memory"   => "-v",
	 "locked_memory"    => "-l"
	}.each do |attr, opt|
		context "when 'limit_#{attr} => 42'" do
			let(:params) { { :command        => "/bin/true",
			                 :user           => "fred",
			                 "limit_#{attr}" => 42
			             } }
			
			it do
				should contain_file('/var/lib/service/rspecsvc/run').
				       with_content(/^ulimit #{opt} 42$/)
			end
		end
	end
	
	context "when 'umask => 0003'" do
		let(:params) { { :command => "/bin/true",
		                 :user    => "fred",
		                 :umask   => "0003"
		             } }
		
		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(/^umask 0003$/)
		end
	end
	
	context "when 'pre_command => singlecommand'" do
		let(:params) { { :command   => "/bin/true",
		                 :user      => "fred",
		                 :pre_command => "/bin/mkdir /var/run/ffs"
		             } }
		
		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(%r{^/bin/mkdir /var/run/ffs$})
		end
	end
	
	context "when 'pre_command => string of commands'" do
		let(:params) { { :command   => "/bin/true",
		                 :user      => "fred",
		                 :pre_command => "/bin/mkdir /var/run/ffs\n/bin/touch /my/self"
		             } }
		
		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(%r{^/bin/mkdir /var/run/ffs$})
		end

		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(%r{^/bin/touch /my/self$})
		end
	end

	context "when 'pre_command => array of commands'" do
		let(:params) { { :command   => "/bin/true",
		                 :user      => "fred",
		                 :pre_command => ["/bin/mkdir /var/run/ffs", "/bin/touch /my/self"]
		             } }
		
		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(%r{^/bin/mkdir /var/run/ffs$})
		end

		it do
			should contain_file('/var/lib/service/rspecsvc/run').
			       with_content(%r{^/bin/touch /my/self$})
		end
	end
end
