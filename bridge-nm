#!/bin/bash

# Função para exibir ajuda
show_help() {
    echo "Uso: $0 [opções]"
    echo
    echo "Opções:"
    echo "  -c <nome>                Criar conexão Ethernet 'Cabeada' com o nome especificado"
    echo "  -b <nome>                Criar conexão Bridge com o nome especificado"
    echo "  -i <ip>                  Endereço IP para a configuração da Bridge (use com -b)"
    echo "  -g <gateway>             Gateway para a configuração da Bridge (use com -b)"
    echo "  -r <nome>                Remover a conexão especificada"
    echo "  -a                       Remover todas as conexões"
    echo "  -l                       Listar todas as conexões"
    echo "  -p                       Listar todas as pontes"
    echo "  -h                       Exibir esta ajuda"
    echo
    echo "Exemplos:"
    echo "  $0 -c Cabeada             Cria uma conexão Ethernet 'Cabeada'"
    echo "  $0 -b br0 -i 192.168.15.222/24 -g 192.168.15.1"
    echo "                            Cria uma conexão Bridge 'br0' com IP e Gateway especificados"
}

# Função para verificar se uma conexão existe
check_connection_exists() {
    local name="$1"
    nmcli connection show | grep -q "^$name "
}

# Função para validar o formato de um endereço IP
is_valid_ip() {
    local ip="$1"
    local valid_ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$"
    if [[ "$ip" =~ $valid_ip_regex ]]; then
        return 0  # Verdadeiro
    else
        return 1  # Falso
    fi
}

# Função para gerar um nome automático para a bridge
generate_bridge_name() {
    local base="br"
    local num=0
    while check_connection_exists "${base}${num}"; do
        ((num++))
    done
    echo "${base}${num}"
}

# Função para criar a conexão Bridge com configurações especificadas
create_bridge() {
    local bridge_name="$1"
    local ipv4_address="$2"
    local ipv4_gateway="$3"
    local bridge_ageing_time=299
    local ipv4_method

    # Define o método IPv4 conforme as variáveis de IP e gateway
    if [[ -z "$ipv4_address" || -z "$ipv4_gateway" ]]; then
        ipv4_method="auto"
        echo "Nenhum endereço IP ou gateway especificado. Usando o método IPv4 'auto'."
    else
        ipv4_method="manual"
    fi

    echo "Criando conexão '$bridge_name' para Bridge..."

    # Cria a conexão do tipo bridge com configurações especificadas
    nmcli connection add type bridge ifname "$bridge_name" con-name "$bridge_name"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao criar a conexão '$bridge_name'."
        exit 1
    fi

    nmcli connection modify "$bridge_name" connection.autoconnect no
    nmcli connection modify "$bridge_name" connection.interface-name "$bridge_name"
    nmcli connection modify "$bridge_name" bridge.ageing-time "$bridge_ageing_time"

    # Configura IPv4 conforme o método escolhido
    if [[ "$ipv4_method" == "manual" ]]; then
        nmcli connection modify "$bridge_name" ipv4.addresses "$ipv4_address"
        nmcli connection modify "$bridge_name" ipv4.gateway "$ipv4_gateway"
        nmcli connection modify "$bridge_name" ipv4.method manual
    else
        nmcli connection modify "$bridge_name" ipv4.method auto
    fi

    nmcli connection modify "$bridge_name" ipv6.addr-gen-mode stable-privacy
    nmcli connection modify "$bridge_name" ipv6.method auto

    echo "Conexão '$bridge_name' configurada com sucesso!"
}

# Função para criar a conexão Ethernet 'Cabeada' com configurações especificadas
create_cabeada() {
    local name="$1"
    local controller="br0"
    local timestamp=$(date +%s)  # Gera o timestamp atual automaticamente

    echo "Criando conexão '$name' para Ethernet..."

    # Cria a conexão Ethernet e configura o controlador e o timestamp
    nmcli connection add type ethernet ifname "$controller" con-name "$name"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao criar a conexão '$name'."
        exit 1
    fi

    nmcli connection modify "$name" connection.controller "$controller"
    nmcli connection modify "$name" connection.port-type bridge
    nmcli connection modify "$name" connection.timestamp "$timestamp"

    echo "Conexão '$name' criada com sucesso!"
}

# Função para remover uma conexão específica
remove_connection() {
    local name="$1"
    if check_connection_exists "$name"; then
        echo "Removendo conexão '$name'..."
        nmcli connection delete "$name"
        if [[ $? -ne 0 ]]; then
            echo "Erro ao remover a conexão '$name'."
            exit 1
        fi
        echo "Conexão '$name' removida com sucesso!"
    else
        echo "Conexão '$name' não encontrada."
    fi
}

# Função para remover todas as conexões
remove_all_connections() {
    echo "Removendo todas as conexões..."
    for conn in $(nmcli -t -f NAME connection show); do
        nmcli connection delete "$conn"
        if [[ $? -ne 0 ]]; then
            echo "Erro ao remover a conexão '$conn'."
        fi
    done
    echo "Todas as conexões foram removidas!"
}

# Função para listar todas as conexões
list_connections() {
    echo "Conexões atuais do NetworkManager:"
    nmcli connection show
}

# Função para listar todas as pontes
list_bridges() {
    echo "Pontes atuais:"
    brctl show
}

# Verifica se os comandos necessários estão disponíveis
if ! command -v ip >/dev/null || ! command -v brctl >/dev/null || ! command -v nmcli >/dev/null; then
    echo "Por favor, instale as dependências antes de executar o comando."
    exit 1
fi

# Processa as opções de linha de comando
if [[ "$#" -gt 0 ]]; then
    # Verifica se todos os argumentos começam com '-'
    for arg in "$@"; do
        if [[ "$arg" != -* ]]; then
            echo "Erro: todos os argumentos devem começar com '-'."
            show_help  # Exibe a ajuda
            exit 1
        fi
    done
    while getopts "c:b:i:g:r:alph" opt; do
        case $opt in
            c)
                # Cria conexão Ethernet 'Cabeada'
                create_cabeada "$OPTARG"
                exit 0  # Finaliza após a criação
                ;;
            b)
                # Cria conexão Bridge com o nome especificado
                bridge_name="$OPTARG"
                ;;
            i)
                # Endereço IP para a configuração da Bridge
                if ! is_valid_ip "$OPTARG"; then
                    echo "Erro: Endereço IP '$OPTARG' é inválido."
                    exit 1
                fi
                ipv4_address="$OPTARG"
                ;;
            g)
                # Gateway para a configuração da Bridge
                ipv4_gateway="$OPTARG"
                ;;
            r)
                # Remove uma conexão específica
                remove_connection "$OPTARG"
                exit 0  # Finaliza após a remoção
                ;;
            a)
                # Remove todas as conexões
                remove_all_connections
                exit 0  # Finaliza após a remoção
                ;;
            l)
                # Lista todas as conexões
                list_connections
                exit 0  # Finaliza após a listagem
                ;;
            p)
                # Lista todas as pontes
                list_bridges
                exit 0  # Finaliza após a listagem
                ;;
            h)
                # Exibe a ajuda
                show_help
                exit 0
                ;;
            \?)
                echo "Opção inválida: -$OPTARG" >&2
                show_help
                exit 1
                ;;
        esac
    done

    # Verifica se a opção de criar bridge foi chamada
    if [[ -n "$bridge_name" ]]; then
        if check_connection_exists "$bridge_name"; then
            echo "A conexão '$bridge_name' já existe. Escolha um nome diferente ou remova a conexão existente."
            exit 1
        fi
        create_bridge "$bridge_name" "$ipv4_address" "$ipv4_gateway"
        exit 0  # Finaliza após a criação da bridge
    fi
else
    # Se não houver opções, exibe o menu interativo
    clear
    while true; do
        echo "Escolha uma opção:"
        echo "1) Criar conexão 'Cabeada' (Ethernet)"
        echo "2) Criar conexão 'Bridge' com nome e IP personalizados"
        echo "3) Remover uma conexão específica"
        echo "4) Remover todas as conexões"
        echo "5) Listar todas as conexões"
        echo "6) Listar todas as pontes"
        echo "7) Sair"
        read -p "Opção: " option

        case $option in
            1)
                read -p "Digite o nome da nova conexão Ethernet: " name
                create_cabeada "$name"
                sleep 2
                clear
                ;;
            2)
                read -p "Digite o nome da nova conexão Bridge: " bridge_name
                read -p "Digite o endereço IP (ou deixe vazio para auto): " ipv4_address
                if [[ -n "$ipv4_address" ]] && ! is_valid_ip "$ipv4_address"; then
                    echo "Erro: Endereço IP '$ipv4_address' é inválido."
                    continue
                fi
                read -p "Digite o gateway (ou deixe vazio para auto): " ipv4_gateway
                create_bridge "$bridge_name" "$ipv4_address" "$ipv4_gateway"
                sleep 2
                clear
                ;;
            3)
                read -p "Digite o nome da conexão que deseja remover: " name
                remove_connection "$name"
                sleep 2
                clear
                ;;
            4)
                remove_all_connections
                sleep 2
                clear
                ;;
            5)
                clear
                list_connections
                ;;
            6)
                clear
                list_bridges
                ;;
            7)
                echo "Saindo..."
                exit 0
                ;;
            *)
                echo "Opção inválida. Tente novamente."
                ;;
        esac
    done
fi
