#!/usr/bin/env bash
echo "-------------------------------------------------------------------------------------------------"
echo " Network Configuration Generator - Centos 7"
echo "-------------------------------------------------------------------------------------------------"
echo ""
echo "This script stages the \"Network Configuration Generator\" Web service on the host. It installs"
echo "all dependencies, including nginx and gunicorn."
echo ""
echo "The script will create a new user \"ncg\", that is used to run the service."
echo ""
echo "PLEASE NOTE: This script assumes, that this Web service is the only application running on "
echo "the host."
echo "" PLEASE NOT THE CENTOS 7 VERSION OF THIS WAS WRITTEN BY A DUMMY!
echo "-------------------------------------------------------------------------------------------------"

echo "Do you wish to continue?"
select result in Yes No
do
    case ${result} in
        "Yes" )
            extra_vars=""
            echo "Are you using Centos or Redhat? (Assumes Systemd)"
            select sub_result in Yes No
            do
                case ${sub_result} in
                    "Yes" )
                        extra_vars+=" use_systemd=true"
                        break
                        ;;
                    *)
                        break
                        ;;
                esac
            done

            echo "---------------------------------"
            echo "Do you want to configure the local services (FTP/TFTP)?"
            echo "---------------------------------"
            select sub_result in Yes No
            do
                case ${sub_result} in
                    "Yes" )
                        extra_vars+=" configure_local_services=true"
                        break
                        ;;
                    *)
                        break
                        ;;
                esac
            done

            echo "---------------------------------"
            echo "Install Ansible...and develepment tools"
	    echo "---------------------------------"
	    sudo yum install epel-release -y
	    sudo yum update -y
 	    sudo yum install ansible -y
 	    yum groupinstall Development\ Tools -y

	    echo "---------------------------------"
	    echo "create Network Configuration Generator user..."
	    echo "---------------------------------"
	    sudo adduser ncg -d /home/ncg
	    sudo usermod -aG wheel ncg
	    sudo passwd -d ncg

	    echo "---------------------------------"
	    echo "copy source files to /var/www/network_config_generator"
	    echo "---------------------------------"
	    source_dir="/var/www/network_config_generator"

	    sudo mkdir -p ${source_dir}
	    sudo chown ncg ${source_dir}
	    sudo chgrp ncg ${source_dir}
	    sudo -u ncg cp -r * ${source_dir}

	    echo "---------------------------------"
	    echo "Setup of the Network Configuration Generator Web service..."
	    echo "---------------------------------"
	    cd ${source_dir}

            ansible-playbook -i 'localhost,' -c local deploy_centos/setupCentos.yaml --ask-sudo-pass --extra-vars "${extra_vars}" -vv

            echo "---------------------------------"
            echo "Setup complete."
            echo ""
            break
            ;;
        * )
            echo "Okay, exit setup."
            break
            ;;
    esac
done
