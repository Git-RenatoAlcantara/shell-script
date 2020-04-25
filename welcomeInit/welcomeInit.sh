#!/bin/bash
#=========HEADER===========================================================|
#AUTOR
# Renato Alcantara <renato.forjob@gmail.com>
#PROGRAMA
#WelcomeInit é uma ferramenta para auxiliar na recuperação
#do sistema. Após me ver com o sistema travado ao reniciar no modo texto
#fui obrigado a reinstalar o sistema só que sem ter um pendrive
#bootavel e sem acesso ao modo gráfico para tal, resolvi criar
#essa ferramenta.
#==========================================================================|


#=====CORES TERMINAL=====================|
# cores das letras no terminal
vermelho="\033[31;1m"
verde="\033[32;1m"
branco="\033[37;1m"
#========================================|


#========VARIAVEIS===============================================|


declare -a tamanhoDispositivo
declare -a nomesDispositivo
user=$(echo $whoami)

#================================================================|

#===========IMPORTE==========================|
dir=$(echo ~/Documentos/shell/welcomeInit/ )
source "${dir}/dispositivo"
#============================================|



#========ESCOLHA DO USUARIO====================================|
escolha(){
	case $1 in
		1) aptitudeDownload				;; #baixar o gerenciador aptitude
		2) echo "VLC" 					;; #baixa o vlc
		3) clear ; formatarHD -f 		;;
		4) clear ; printDispositivos   	;;
		5) clear ; baixarDistro         ;; 	
		6) clear ; comandosLinux     	;;
		7) clear ; exit 1 				;;
		*) clear; menu					;;
	esac
}

#==============================================================|

#===========IMPRIME DICAS DE COMANDOS LINUX=====================|
comandosLinux(){
 printf """
==========================================================
| xkill | Transforma o mouse em um matador de processos. |
==========================================================
| shift+PageUp | Paginação no terminal em modo texto     |
============================================================
| wipefs -a /dev/sdX | Apagar partição de um pendrive ou HD|
============================================================

 """

}

#===============================================================
#===========BAIXAR DISTRO=======================================|
baixarDistro(){
	printf """
===========================
| 1) Instalar iso Minimal |
===========================
| 2 ) Ubuntu 18.04        |
===========================
| 3 ) Sair                |
===========================
"""
 read -p "Escolha: " distro
 if [[ "$distro" = 1 ]]; then
 	wget http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso --show-progress
 	clear
 elif [[ "$distro" = 2 ]]; then
 	wget http://old-releases.ubuntu.com/releases/bionic/ubuntu-18.04-desktop-amd64.iso --show-progress
 	clear
 else
 	exit 
 fi

}
#=================================================================|






pendriveBootavel(){
	echo "Digite o caminho da  iso."
	read -p "caminho> " escolha

	if [[ -n "$1" ]] && [[ "$1" != "" ]]; then
		clear
		dd if="$caminho" of="$1" status=progress && sync
		#pv -EE "$fullPath" > "$modPontoMont" | pv -p -e -t -a -r
		

	fi
}



printDispositivos(){
#============== VARIAVEIS ====================================|
	contador=0
#=============================================================|
	listaTodos=$(fdisk -l | grep Disco)


#================== PEGA O CAMINHO DA MONTAGEM - /dev/sdb============================================================|
	montagemExterna=$(echo "$listaTodos" | egrep -A 2 -o "\/dev\/[a-z]{3}:" | sed 's/://g' | egrep -v "/dev/sda" | sed 's/--//g')
#====================================================================================================================|

#===================PEGA OS GIGAS=======================================================|
	dispositivosMemoria=$(echo "$listaTodos" | egrep   -A 2 "\dev\/sd" | cut -d" " -f3 )
	memoriaMaxima=$(echo $dispositivosMemoria | cut -d" " -f5-)
#=======================================================================================|

#================ADICIONA MEMORIA EM UM ARRAY==========================================|
	for listaMemoria in $memoriaMaxima; do
		(( contador++ ))
		recebeMemoria[$contador]=$listaMemoria
	done
#=======================================================================================|

#================PEGA A ETIQUETA DO DISPOSITIVO=========================================|
	dipositivosEtiqutas=$(lsblk | grep sd | grep part | sed '1d' | cut -d" " -f14)
#=======================================================================================|
	contador=0
#================ADICIONA AS ETIQUTAS EM UM ARRAY=======================================|
	for listEtiquetas in $dipositivosEtiqutas; do
		(( contador++ ))
		recebeEtiquetas[$contador]=$listEtiquetas
	done
#=======================================================================================|


#===============PRINTA DADOS DO SISTEMA=================================================|
	caminhoMontagem=$(echo "$listaTodos" | grep "/dev/sda" | cut -d" " -f2 | sed 's/://g')
	gigas=$(echo "$listaTodos" | grep "/dev/sda" | cut -d" " -f3)

cat <<FECHA
=============================================================
| ${caminhoMontagem} | ${gigas} | sistama
=============================================================
FECHA
#=======================================================================================|

	contador=0
#================PRINTA DADOS DISPOSITIVOS EXTERNOS NA TELA=============================|

	for listaMontagem in $montagemExterna; do
		(( contador++ ))
		listaDispositivo[(($contador - 1))]=$listaMontagem

cat <<FECHA
=============================================================
|${contador} ) $listaMontagem | ${recebeMemoria[$contador]} | ${recebeEtiquetas[$contador]}
=============================================================
FECHA
	done

#=======================================================================================|

	echo "Escolha a opção acima."
	read -p "Excolha> " response
	pendriveBootavel $(echo $montagemExterna | cut -d" " -f"$response" )
}



listaArquivos(){
	count=0
	comando=$(ls ~/$1)
	IFs=\n
	while read files; do
		(( count++ ))
		lista[$count]=$files
echo "============================================================"
echo "|${count} ) ${files}"

	done <<< $comando
	echo "Digite numero que corresponde a iso."
	read -p "Escolha> " escolha
	dirCompleto=$(echo ~/$1/"${lista[$escolha]}") 
	

}

formatar(){
	pontoDeMontagem=$(echo "${1}" | sed 's/://g')

	umount "$pontoDeMontagem"
	echo "$?"
	 if [[ "$?" = "0" ]]; then
	 	sudo mkfs.vfat -I -v -n "$2" "$pontoDeMontagem" | pv -p -e -t -a -r
	 	
	 fi
}

obterDispositivos(){

		pontoDeMontagem=$(lsblk | cut -d" " -f1 | egrep -o "sd[a-z]{1}[^\d]") #obtem o caminho da montagem como: /dev/sda


}



aptitudeDownload(){
	if type -P aptitude > /dev/null 2>&1; # comando type -P verifica se o aptitude está instalado.  
		then
			jaInstalado
	fi
}

jaInstalado(){
	clear
	echo "Pacote já instalado."
	read -p "Deseja continuar? [S/n] :" escolha
	if [[ $escolha = "S" ]] || [[ $escolha = "s" ]]
		then
			menu
	fi
	exit 1
}

menu(){

#========BOAS VINDAS=======================================================|
clear
cat <<FECHA

 __      __       .__                              .___       .__  __   
/  \    /  \ ____ |  |   ____  ____   _____   ____ |   | ____ |__|/  |_ 
\   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \|   |/    \|  \   __\
 \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/|   |   |  \  ||  |  
  \__/\  /  \___  >____/\___  >____/|__|_|  /\___  >___|___|  /__||__|  
       \/       \/          \/            \/     \/         \/          

FECHA

#==========================================================================|

	printf "Escolha seu pacote para ser feito a instalação.\n"
	printf """
====================
| 1 ) Aptitude     |
|==================|
| 2 ) VLC player   |
|==================|
| 3 ) formatarHD   |
|==================|
| 4 ) PendriveBoot |
|==================|
| 5 ) BaixarDistro |
|==================|
| 6 ) Cmd Linux    |
|==================|
| 7 ) Sair         |
====================
\n""" | pv -qL 70
 read -p "Escolha>" response # recebendo a ecolha do usuario
 escolha $response 	  # enviando a reposta para a função escolha

 }

if [[ $UID -ne 0 ]]; then
	echo "Execute $0 como root"
	exit 1
fi
menu
