#!/bin/bash
clear

#Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

show_options() {
	echo -e "${blueColour}"
 printf '
 .d8888b.           888    8888888b.                                    
d88P  Y88b          888    888   Y88b                                   
Y88b.               888    888    888                                   
 "Y888b.    .d88b.  888888 888   d88P 888d888 .d88b.  888  888 888  888 
    "Y88b. d8P  Y8b 888    8888888P"  888P"  d88""88b `Y8bd8P 888  888 
      "888 88888888 888    888        888    888  888   X88K   888  888 
Y88b  d88P Y8b.     Y88b.  888        888    Y88..88P .d8""8b. Y88b 888 
 "Y8888P"   "Y8888   "Y888 888        888     "Y88P"  888  888  "Y88888 
                                                                    888 
                                                               Y8b d88P 
                                                                "Y88P"  
 '
 echo -e "      ${turquoiseColour}                             Script by mrhat_cu\n ${endColour}"
 echo -e "   ${greenColour}       .::Opciones::.
[1]${endColour} Proxy para apt
${greenColour}[2] ${endColour}Proxy del sistema
${greenColour}[3] ${endColour}Proxy Curl
${greenColour}[4] ${endColour}Proxy Git
${greenColour}[5] ${endColour}Usar proxy global
${greenColour}[6] ${endColour}Reestablecer configuración original
${greenColour}[0] ${endColour}Salir"
echo -ne "\n${yellowColour}[?]${endColour} seleccione la opción deseada -> " && read -r option
echo ""
}

hide_pass (){
	echo -ne "${yellowColour}[?]${endColour} Contraseña: "
	Prompt=" "
	while temp= read -p "$Prompt" -r -s -n 1 char
	do
	if [[ $char == $'\0' ]]; then
    	break

	elif [[ $char == $'\177' ]]; then
    	Prompt=$'\b \b'
    	pass="${pass%?}"
	else
    	Prompt='*'
    	pass+="$char"
	fi
	done
}

get_info (){
	clear
	echo -ne "${yellowColour}[?]${endColour} ¿Usar autenticación? (y/n): " && read -r auth
	if [[ "$auth" = y ]]; then
		clear
		echo -ne "${yellowColour}[?]${endColour} Nombre de usuario: " && read -r user
		hide_pass
		printf "\n"
		echo -ne "${yellowColour}[?]${endColour} Servidor proxy: " && read -r proxy
		echo -ne "${yellowColour}[?]${endColour} Puerto: " && read -r puerto
	elif [[ "$auth" = n ]]; then
		clear
		echo -ne "${yellowColour}[?]${endColour} Servidor proxy: " && read -r proxy
		echo -ne "${yellowColour}[?]${endColour} Puerto: " && read -r puerto
	else
		get_info
	fi
}

set_apt(){
	echo -e "${blueColour}[i]${endColour} Estableciendo proxy en apt... "
	sleep 0.5
	if ! [ $(id -u) = 0 ]; then
        echo -e "${redColour}[!] ${endColour}$programa Necesita permisos de root para cambiar esta configuración"
        sleep 0.5
	elif [[ "$auth" = y ]]; then
		echo 'Acquire::http::Proxy "http://'$user':'$pass'@'$proxy':'$puerto'/";' > /etc/apt/apt.conf.d/proxy.conf
		echo 'Acquire::https::Proxy "http://'$user':'$pass'@'$proxy':'$puerto'/";' >> /etc/apt/apt.conf.d/proxy.conf
		echo 'Acquire::ftp::Proxy "http://'$user':'$pass'@'$proxy':'$puerto'/";' >> /etc/apt/apt.conf.d/proxy.conf
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo "
	elif [[ "$auth" = n ]]; then
		echo 'Acquire::http::Proxy "http://'$proxy':'$puerto'/";' > /etc/apt/apt.conf.d/proxy.conf
		echo 'Acquire::https::Proxy "http://'$proxy':'$puerto'/";' >> /etc/apt/apt.conf.d/proxy.conf
		echo 'Acquire::ftp::Proxy "http://'$proxy':'$puerto'/";' >> /etc/apt/apt.conf.d/proxy.conf
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo "
	fi
	sleep 1
}

set_environment(){
	echo -e "${blueColour}[i]${endColour} Estableciendo proxy del sistema... "
	sleep 0.5
	if ! [ $(id -u) = 0 ]; then
        echo -e "${redColour}[!] ${endColour}$programa Necesita permisos de root para cambiar esta configuración"
        sleep 0.5
	elif [[ "$auth" = y ]]; then
		if [ ! -f /etc/evironment.backup ]; then
			echo -e "${blueColour}[i]${endColour} Creando un backup de /etc/environment... "
			cp /etc/environment /etc/environment.backup
			sleep 0.5
		fi
		cat /etc/environment.backup > /etc/environment
		echo '#Configuracion de proxy escrita por set-proxy' >> /etc/environment
		echo 'http_proxy="http://'$user':'$pass'@'$proxy':'$puerto'/"' >> /etc/environment
		echo 'https_proxy="http://'$user':'$pass'@'$proxy':'$puerto'/"' >> /etc/environment
		echo 'ftp_proxy="http://'$user':'$pass'@'$proxy':'$puerto'/"' >> /etc/environment
		echo -e "${yellowColour}[?]${endColour} No usar proxy para (Ej: localhost,*midominio.com,192.168.0.0/24): " && read -r noproxyfor
	    echo 'no_proxy='$noproxyfor >> /etc/environment
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo."
	elif [[ "$auth" = n ]]; then
		if [ ! -f /etc/enviroment.backup ]; then
			echo -e "${blueColour}[i]${endColour} Creando un backup de /etc/environment... "
			cp /etc/environment /etc/environment.backup
			sleep 0.5
		fi
		cat /etc/environment.backup > /etc/environment
		echo '#Configuracion de proxy escrita por set-proxy' >> /etc/environment
		echo 'http_proxy="http://'$proxy':'$puerto'/"' >> /etc/environment
		echo 'https_proxy="http://'$proxy':'$puerto'/"' >> /etc/environment
		echo 'ftp_proxy="http://'$proxy':'$puerto'/"' >> /etc/environment
		echo -e "${yellowColour}[?]${endColour} No usar proxy para (Ej: localhost,*midominio.com,192.168.0.0/24): " && read -r noproxyfor
    	echo 'no_proxy='$noproxyfor >> /etc/environment
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo."

	fi
	sleep 1
}

set_curl(){
	echo -e "${blueColour}[i]${endColour} Estableciendo proxy en curl... "
	if [[ "$auth" = y ]]; then
		echo 'proxy = '$proxy':'$puerto > $HOME/.curlrc
		echo 'proxy-user = '$user':'$pass >> $HOME/.curlrc
	elif [[ "$auth" = n ]]; then
		echo 'proxy = '$proxy':'$puerto >> $HOME/.curlrc
	fi
	sleep 0.5
	echo -e "${blueColour}[i]${endColour} Listo."
	sleep 1
}

set_git(){
	echo -e "${blueColour}[i]${endColour} Estableciendo proxy en git... "
	sleep 1
	if [ "$(command -v git)" ]; then
		if [[ "$auth" = y ]]; then
		git config --global http.proxy http://$user:$pass@$proxy:$puerto
		elif [[ "$auth" = n ]]; then
		git config --global http.proxy http://$proxy:$puerto
		fi
		sleep 1
		echo -e "${blueColour}[i]${endColour} Listo"
		sleep 1
	else
		echo -e "${redColour}[x]${endColour} Git no está instalado"
		sleep 1
	fi
	
}

###Programa Principal##
show_options
until [[ "$option" = 0 ]]; do
	if [[ "$option" = 1 ]]; then
		get_info
		set_apt
		clear
		show_options
	elif [[ "$option" = 2 ]]; then
		get_info
		set_environment
		clear
		show_options
	elif [[ "$option" = 3 ]]; then
		get_info
		set_curl
		clear
		show_options
	elif [[ "$option" = 4 ]]; then
		get_info
		set_git
		clear
		show_options
	elif [[ "$option" = 5 ]]; then
		get_info
		set_apt
		set_environment
		set_curl
		set_git
		echo -e "\n${blueColour}[i]${endColour} Completado, presione cualquier tecla para continuar " && read -p
		clear
		show_options
	elif [[ "$option" = 6 ]]; then
		echo -e "${blueColour}[i]${endColour} Reestableciendo configuración original... "
		sleep 0.5
		if [ -f /etc/apt/apt.conf.d/proxy.conf ]; then
			echo -e "${blueColour}[i]${endColour} Reestableciendo apt... "
			if ! [ $(id -u) = 0 ]; then
        	echo -e "${redColour}[!] ${endColour}$programa Necesita permisos de root para cambiar esta configuración"
        	sleep 0.5
			else
				rm /etc/apt/apt.conf.d/proxy.conf
				sleep 0.5
				echo -e "${blueColour}[i]${endColour} Listo"
				sleep 1
			fi
		fi
		if [ -f /etc/environment.backup ]; then
			echo "Reestableciendo proxy del sistema..."
			if ! [ $(id -u) = 0 ]; then
        		echo -e "${redColour}[!] ${endColour}$programa Necesita permisos de root para cambiar esta configuración"
			else
				rm /etc/environment
				mv /etc/environment.backup /etc/environment
				sleep 0.5
				echo -e "${blueColour}[i]${endColour} Listo"
				sleep 1
			fi
		fi
		echo "Reestableciendo Curl..."
		rm $HOME/.curlrc
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo"
		sleep 1
		echo "Reestableciendo Git..."
		rm $HOME/.gitconfig
		sleep 0.5
		echo -e "${blueColour}[i]${endColour} Listo"
		sleep 1
		echo -e "\n${blueColour}[i]${endColour} Se ha reestablecido la configuración, presione cualquier tecla para continuar " && read -p
		clear
		show_options
	else
		show_options
	fi
done
clear