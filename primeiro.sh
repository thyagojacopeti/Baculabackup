#!/bin/bash

echo "Digite o seu nome: "
read NOME
if [ $NOME == "Thyago" ]; then
	echo "Acesso negado"
	exit 1
fi

echo "USUARIO: $NOME LOGOU AS "$(date +"%d/%m/%Y %H:%M") >> sistema.log
echo "Seja Bem Vindo "$NOME
