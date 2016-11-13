#!/bin/bash
#
#Data: 13/11/2016
#Autor: Thyago Jacopeti
#Script criado para gerenciar backups
#

function cadastrar(){
	echo "Digite o ip: "
	read IP
	grep "\<$IP\>" banco.txt
	if [ $? -eq 0 ]; then
		echo "Servidor já cadastrado"
		exit
	fi

	echo "Digite os diretorios: "
	read DIRETORIOS
	echo "$IP:$DIRETORIOS" >> banco.txt
}

function backup(){
	for LINHA in $(cat /root/codigos/banco.txt); do
		IP=$( echo $LINHA | cut -f1 -d":")
		DIRETORIOS=$( echo $LINHA | cut -f2 -d":")
		echo "Fazendo backup de: "$IP
		echo "Dos Diretorios: "$DIRETORIOS
	  	DATA=$(date +"%d_%m_%Y_%H_%M")
		ssh root@$IP "tar -zcf /tmp/${IP}_${DATA}.tar.gz $DIRETORIOS"
		scp root@$IP:/tmp/*.tar.gz /backup/
		ssh root@$IP "rm -f /tmp/*.tar.gz"
		sleep 5
		done
}

function listar(){
	cat banco.txt
}

function remover(){
	echo "Digite o ip do servidor: "
	read IP
	sed "/\<$IP\>/d" banco.txt
	echo "Deseja mesmo remover? (y/n)"
	read OP
	OP=$(echo $OP | tr [:upper:] [:lower:])
	if [ $OP == "y" ]; then
		sed -i "/\<$IP\>/d" banco.txt
	fi
} 

function menu(){

	echo "cadastrar - para cadastrar novos servidores"
	echo "remover - remover servidores"
	echo "listar - lista de servidores"
	echo "backup - gerar backup dos servidores"
}

if [ $# -eq 0 ]; then
	menu
fi

case $1 in
	"cadastrar")
		cadastrar 
	;;
	"remover")
		remover
	;;
	"listar")
		listar
	;;
	"backup")
		backup
	;;
	*)
		echo "opcao invalida"
	;;
esac


