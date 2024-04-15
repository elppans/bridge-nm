# Configuração de Rede Bridge com nmcli

Este repositório contém um script chamado `bridge_nmcli.sh` que facilita a configuração de uma rede bridge no Linux usando o utilitário `nmcli`.  
A ponte (bridge) é uma interface virtual que combina várias interfaces físicas em uma única interface lógica. Ela pode ser útil para cenários como balanceamento de carga, alta disponibilidade ou segmentação de tráfego.  

## Como Usar

1) Clone este repositório para o seu sistema local:

```
git clone https://github.com/elppans/bridge_nmcli.git
```

2) Navegue até o diretório do repositório:  

```
cd bridge_nmcli
```
3) Execute o script para configurar a rede bridge:

```
./bridge_nmcli.sh auto
```

- A opção `auto` atribui o mesmo IP da interface de rede principal à ponte.


4) Verifique a conectividade e ajuste outras configurações conforme necessário.  

## Dependências  

Certifique-se de ter os seguintes pacotes instalados:

>iproute2  
bridge-utils  
NetworkManager  
