# bridge-nm

## Script `simples` de Gerenciamento de Conexões de Rede em Bridge

Este é um script `simples` em Bash que facilita a criação, remoção e listagem de conexões de rede no Linux usando o `NetworkManager`. Ele suporta conexões Ethernet, Wi-Fi e Bridges, além de permitir a configuração de IPs e gateways.

## Pré-requisitos

Antes de usar o script, verifique se você possui as seguintes ferramentas instaladas:

- `nmcli` (NetworkManager Command Line Interface)
- `brctl` (Bridge Control)
- `ip` (utilitário de manipulação de rede)

Você pode instalá-las usando o gerenciador de pacotes da sua distribuição Linux. Por exemplo:

- **No Debian, Ubuntu ou derivados:**

    ```bash
    sudo apt install network-manager bridge-utils iproute2
    ```

- **No Fedora:**

    ```bash
    sudo dnf install NetworkManager bridge-utils iproute
    ```

- **No openSUSE:**

    ```bash
    sudo zypper install NetworkManager bridge-utils iproute2
    ```

- **No CentOS ou RHEL:**

    ```bash
    sudo dnf install NetworkManager bridge-utils iproute
    ```

- **No Arch Linux ou Manjaro:**

    ```bash
    sudo pacman -S networkmanager bridge-utils iproute2
    ```

- **No Linux Mint:**

    ```bash
    sudo apt install network-manager bridge-utils iproute2
    ```

## Uso

### Executando o Script

Para executar o script, abra um terminal e use o seguinte comando:

```bash
bridge-nm [opções]
```

### Opções

As opções disponíveis são:

- `-c <nome>`: Cria uma conexão Ethernet "Cabeada" com o nome especificado.
- `-b <nome>`: Cria uma conexão Bridge com o nome especificado.
- `-i <ip>`: Especifica o endereço IP para a configuração da Bridge (use com `-b`).
- `-g <gateway>`: Especifica o gateway para a configuração da Bridge (use com `-b`).
- `-r <nome>`: Remove a conexão especificada.
- `-a`: Remove todas as conexões.
- `-l`: Lista todas as conexões atuais do NetworkManager.
- `-w <ssid>`: Cria uma conexão Wi-Fi com o SSID especificado e solicita uma senha interativa.
- `-h`: Exibe a ajuda.

### Exemplos

- Criar uma conexão Ethernet "Cabeada":

```bash
bridge-nm -c NomeDaConexao
```

- Criar uma conexão Bridge com IP e Gateway:

```bash
bridge-nm -b br0 -i 192.168.1.10/24 -g 192.168.1.1
```

- Criar uma conexão Wi-Fi:

```bash
bridge-nm -w NomeDoSSID
```

- Remover uma conexão específica:

```bash
bridge-nm -r NomeDaConexao
```

- Remover todas as conexões:

```bash
bridge-nm -a
```

- Listar todas as conexões:

```bash
bridge-nm -l
```

- Listar todas as pontes:

```bash
bridge-nm -p
```

### Modo Interativo

Se você não fornecer nenhuma opção ao executar o script, ele abrirá um menu interativo onde você pode escolher as operações a serem realizadas.

```bash
bridge-nm
```

## Contribuição

Sinta-se à vontade para fazer contribuições ou sugestões. Para relatar problemas, por favor, crie uma nova issue.

## Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

