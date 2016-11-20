#!/bin/bash
#
#Data: 13/11/2016
#Autor: Thyago Jacopeti
#Script criado para gerenciar backups
#

DB_USER="root"
DB="bacula"
DB_PASS="123456"

function cadastrar(){
	echo "Digite o ip: "
	read IP
	echo "Digite os diretorios: "
	read DIRETORIOS
	mysql -u$DB_USER -p$DB_PASS $DB -e "insert into servidores(endereco,diretorios) values('$IP','$DIRETORIOS')"
}

function backup(){

	DADOS=$(mysql -u$DB_USER -p$DB_PASS $DB -r -se "select * from servidores")
	echo "$DADOS" > /tmp/select.tmp
	sed -i "s/\t/:/g" /tmp/select.tmp
	for LINHA in $(cat /tmp/select.tmp); do
		IP=$( echo $LINHA | cut -f2 -d":")
		echo "Fazendo backup do IP: "$IP
		DIRETORIOS=$( echo $LINHA | cut -f3 -d":")
		echo "Fazendo backup de: "$IP
		echo "Dos Diretorios: "$DIRETORIOS
	  	DATA=$(date +"%d_%m_%Y_%H_%M")
		ARQUIVO=$(echo "${IP}_${DATA}.tar.gz")
		INICIO=$(date +"%Y-%m-%d %H:%M:%S")
		ssh root@$IP "tar -zcf /tmp/$ARQUIVO $DIRETORIOS"
		scp root@$IP:/tmp/*.tar.gz /backup/
		ssh root@$IP "rm -f /tmp/*.tar.gz"
		FIM=$(date +"%Y-%m-%d %H:%M:%S")
		mysql -uroot -p123456 backup -e "insert into log(inicio,fim,server,arquivo,status) values('$INICIO','$FIM','$IP','$ARQUIVO','OK')"
		done
}

function listar(){
	mysql -u$DB_USER -p$DB_PASS $DB -e "select * from servidores"
}

function remover(){
	echo "Digite o ip do servidor: "
	read IP
	echo "Deseja mesmo remover? (y/n)"
	read OP
	OP=$(echo $OP | tr [:upper:] [:lower:])
	if [ $OP == "y" ]; then
		mysql -u$DB_USER -p$DB_PASS $DB -e "delete from servidores where endereco='$IP'"
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


