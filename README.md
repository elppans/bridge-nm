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

3) Configure o script para execução:

```
chmod +x bridge_nmcli.sh
```

4) Execute o script para configurar a rede bridge:

```
./bridge_nmcli.sh auto
```

- A opção `auto` atribui o mesmo IP da interface de rede principal à ponte.
- Execute o script sem opções para ver o help.  

5) Verifique a conectividade e ajuste outras configurações conforme necessário.  

## Dependências  

Certifique-se de ter os seguintes pacotes instalados:

>iproute2  
bridge-utils  
NetworkManager

# Arquivo de dependência do Bridge no Network Manager

Além dos pacotes, a rede Bridge também depende de existir um [arquivo de configuração da interface de rede](README.md#network-manager-sem-arquivo-de-configura%C3%A7%C3%A3o-da-interface) ao qual irá fazer ponte.  

## Network Manager sem arquivo de configuração da interface

No Linux usando NetworkManager, as vezes a interface padrão funciona mas não há nenhum arquivo referente no diretório "`/etc/NetworkManager/system-connections/`".  
Se der o comando ls (como super usuário) no diretório dá pra ver se exite algum arquivo.  
Os arquivos tem uma extensão : `.nmconnection`  
Se positivo, verificar com o comando cat para saber se é um arquivo de configuração referente a interface de rede.  
Se notar que não existe nenhum arquivo referente à interface de rede, deve criar a configuração para que seja usada a rede Bridge. Caso contrário, após a próxima reinicilização, a interface não iniciará e portanto a rede Bridge também ficará sem rede.  
Para resolver isso DEVE seguir o que será [explicado adiante](README.md#configura%C3%A7%C3%A3o-de-interfaces-de-rede-com-networkmanager):  

# Configuração de Interfaces de Rede com NetworkManager  

O NetworkManager é uma ferramenta essencial para gerenciar conexões de rede em sistemas Linux. Neste guia, explicarei como identificar interfaces de rede, verificar arquivos de configuração e criar novas interfaces usando o NetworkManager.

## Identificando Interfaces de Rede  

Para listar todas as interfaces de rede disponíveis no seu sistema, execute o seguinte comando:  

```
ip link show
```

Isso exibirá uma lista de interfaces, incluindo as interfaces de loopback (geralmente chamadas de lo) e outras interfaces de rede (como eth0, enp2s0, ens33, wlan0, etc.).  

## Verificando os Arquivos de Configuração  

O NetworkManager armazena as configurações de conexão em arquivos com a extensão `.nmconnection`. Por padrão, esses arquivos estão localizados no diretório `/etc/NetworkManager/system-connections/`.

Para verificar se existem arquivos de configuração para suas interfaces de rede, use o seguinte comando:

```
sudo ls -1 /etc/NetworkManager/system-connections/
```

Se houver arquivos listados, você pode visualizar o conteúdo de um arquivo específico usando o comando cat:

```
sudo cat /etc/NetworkManager/system-connections/nome_do_arquivo.nmconnection
```

>Substitua **`nome_do_arquivo`** pelo nome real do arquivo que você deseja examinar.  

## Criando uma Nova Interface no NetworkManager  

Para criar uma nova interface de rede usando o NetworkManager, você pode usar o utilitário `nmcli`.  

1) Verifique se o NetworkManager está em execução:

```
systemctl status NetworkManager
```

Se não estiver em execução, inicie-o:

```
sudo systemctl start NetworkManager
```

2) Crie uma nova conexão Ethernet com o seguinte comando (substitua os valores conforme necessário):

```
sudo nmcli connection add type ethernet con-name "nome_da_interface" ifname "nome_da_interface"
```

>**`nome_da_interface`**: Escolha um nome significativo para a nova interface.  
**`ifname`**: Especifique o nome da interface de rede física (por exemplo, **eth0**).  

3) Para conexões sem fio (Wi-Fi), use o seguinte comando:

```
sudo nmcli connection add type wifi con-name "nome_da_interface" ifname "nome_da_interface" ssid "nome_da_rede" password "senha_da_rede"
```

>**`ssid`**: Substitua pelo nome da rede Wi-Fi.  
**`password`**: Substitua pela senha da rede Wi-Fi.  

4) Finalmente, ative a nova interface:

```
sudo nmcli connection up "nome_da_interface"
```
Lembre-se de substituir os valores entre aspas pelos valores reais relevantes para o seu sistema.  
