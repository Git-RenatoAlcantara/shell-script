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

#========ESCOLHA DO USUARIO====================================|
escolha(){
	case $1 in
		1) aptitudeDownload;; #baixar o gerenciador aptitude
		2) echo "VLC" ;; 	  #baixa o vlc
		3) clear ; formatarHD -f ;;
		4) clear ; pendriveBootavel ;;
		5) clear ; baixarDistro ;;
		6) clear ; exit 1 ;;
		*) "Opção desconhecida"  ; echo ; clear; menu ;;
	esac
}

#==============================================================|

baixarDistro(){
	printf """
===========================
| 1) Instalar iso Minimal |
===========================
| 2 ) Ubuntu 18.04        |
===========================
"""
 read -p "Escolha: " distro
 if [[ "$distro" = 1 ]]; then
 	wget http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso --show-progress
 else
 	wget http://old-releases.ubuntu.com/releases/bionic/ubuntu-18.04-desktop-amd64.iso --show-progress
 	clear
 fi

}
pendriveBootavel(){
	
	formatarHD
	if [[ -n $bootavel ]] && [[ $bootavel != "" ]]; then
		clear
		#pv -EE /home/renato/Downloads/ubuntu-18.04-desktop-amd64.iso > /dev/sdb | pv -p -e -t -a -r
		dd if=/home/renato/Downloads/ubuntu-18.04-desktop-amd64.iso  of="$bootavel" status=progress && sync
		umount "$bootavel"

	fi
}
formatar(){
	umount "${1}"
	echo "$?"
	 if [[ "$?" = "0" ]]; then
	 	sudo mkfs.vfat -v -n "$2" "${1}" | pv -p -e -t -a -r

	 fi
}
formatarHD(){
	count=0
	numMax=0
	#--- Lista todos os hd's
		listAllHD=$(fdisk -l | grep "Disco /dev/sd")
		IFs=\n
		# printa os dispositivos conetados e o hd do sistema usando o grep para listar apenas os dados como: tamanho e o caminho do mount.
		while read linhas; do
			(( count++ ))
			listAllMountedHD[$count]=$linhas
		done <<< $listAllHD
		
		# separa em um array os dispositivos por tamanho e caminho da montagem.
		count=0
		for dados in "${listAllMountedHD[@]}";do
			(( count++ ))
			montagemList=$(echo $dados |  cut -d" " -f2 )
			tamanhoList[$count]=$(echo $dados |  cut -d" " -f3 )
			remove[$count]=$(echo $dados | cut -d" " -f2 | sed 's/://g')
		done

		# Obtem com o comando lsblk o nome ou label referente ao dispositivo conectado
		# O hd do sistema não vem com a etiqueta.
		listlb=$(lsblk -o "MOUNTPOINT" | grep media\/)
		
		count=0
		IFs=\n

		while read scanner; do
			(( count++ ))
			totallb[count]=$(echo $scanner | cut -d"/" -f4 )
		done <<< $listlb
		
		count=0
		
		for next in "${remove[@]}"; do

			(( count++ ))
			(( numMax++ ))

			if [[ $count = 1 ]]; then
				printf """ 
===========================================================
|${count} )  Sistema   | ${tamanhoList[$count]} | ${remove[$count]}  
===========================================================
"""
			else
				printf """
============================================================
|${count} )  ${totallb[(( count - 1))]} | ${tamanhoList[$count]} | ${remove[$count]}
============================================================
"""

			fi

		done
		echo  "Numero de dispositivos: ${numMax}"
		read -p "Escolha:" response
		if [[ $response -le $numMax ]]; then
			if [[ "$1" = "-f" ]]; then
				read -p "Entre com o nome que deseja para o dispositivo> " name
				formatar "${remove[(( $remove - 1))]}" $name
			fi
			bootavel="${remove[(( $remove - 1))]}"
		fi
		

	#--- Fim

	#--- Obtem o tamanho do hd
		#tamanho=$(fdisk -l | grep  "Disco /dev/sdb" | egrep -o "[0-9]{1},[0-9]{1}")
	#--- Fim
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
| 6 ) Sair         |
====================
\n""" | pv -qL 70
 read -p "Escolha>" response # recebendo a ecolha do usuario
 escolha $response 	  # enviando a reposta para a função escolha

 }

menu
