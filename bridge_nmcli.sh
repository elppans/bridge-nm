#!/bin/bash

# IP Bridge e IP Interface

# Você pode atribuir o mesmo IP à sua ponte (br0) que está configurado na sua interface de rede (enp4s0).
# Isso é comum e muitas vezes necessário para garantir a conectividade correta.

# Quando você cria uma ponte, ela age como uma interface virtual que combina várias interfaces físicas em uma única interface lógica.
# Ao atribuir o mesmo IP à ponte, você está essencialmente permitindo que ela compartilhe o mesmo endereço IP da interface física subjacente.
# Isso cria uma ponte transparente que age como uma extensão da interface física. Pode ser útil em cenários como balanceamento de carga, alta disponibilidade ou segmentação de tráfego.

# Considerações importantes:

# Endereço IP Compartilhado:
# Se você atribuir o mesmo IP à ponte, ela responderá aos pacotes de rede da mesma maneira que a interface física.
# Isso é útil quando você deseja que a ponte seja uma extensão da rede da interface física.

# Conflito de IP:
# O conflito ocorre se ambas a interface física e a ponte estiverem configuradas com o mesmo IP ao mesmo tempo.
# Para evitar conflitos, certifique-se de que a interface física não esteja configurada com o mesmo IP que você está atribuindo à ponte.

# Configuração de IP:
# Se você fixar um IP na ponte, ela poderá se comunicar com outros dispositivos na mesma rede usando esse IP.
# Certifique-se de que o IP atribuído à ponte esteja dentro da mesma sub-rede que o IP da interface física. Por exemplo, se a interface física tem o IP 192.168.15.81, você pode atribuir 192.168.15.82 à ponte.

# Outras Configurações:
# Além do IP, verifique outras configurações relevantes, como máscara de sub-rede, gateway padrão e DNS. Essas configurações devem ser consistentes entre a interface física e a ponte.

# Compartilhar é diferente de configurar igual.
# Compartilhar o mesmo IP significa que a ponte e a interface física respondem aos pacotes de rede da mesma maneira, como uma extensão da mesma rede.

# DEPENDÊNCIAS:

# iproute2: O pacote iproute oferece uma alternativa moderna para ferramentas como ifconfig e route.
# bridge-utils: O pacote bridge-utils também é usado para configurar pontes de rede.
# NetworkManager: O NetworkManager é amplamente usado em muitas distribuições.

# Verifica se os comandos necessários estão disponíveis
if ! command -v ip >/dev/null || ! command -v brctl >/dev/null || ! command -v nmcli >/dev/null; then
    echo "Erro: Este script requer 'iproute2', 'bridge-utils' e 'NetworkManager'."
    echo "Por favor, instale as dependências antes de executar o script."
    exit 1
fi

# Função para exibir a mensagem de ajuda
exibir_ajuda() {
    echo "Uso: $0 [auto|plusone|interface|delete]"
    echo "Opções:"
    echo "  auto       : Configuração automática (mesmo IP da interface principal)"
    echo "  plusone    : Configuração com IP aumentado em 1 (maior que o IP da interface principal)"
    echo "  interface  : Especifica uma interface para configuração (exemplo: $0 interface enp4s0)"
    echo "  delete     : Exclui a rede bridge"
    exit 1
}

# Detecta automaticamente as interfaces de rede físicas (ethernet)
interfaces=$(ip link show up | awk -F ': ' '/^[0-9]+:/ {print $2}' | grep -v '^lo$\|^vmnet\|^vnet\|^virbr\|^br')

# Seleciona a primeira interface detectada como a principal
main_interface=$(echo "$interfaces" | head -n 1)

# Verifica a opção fornecida pelo usuário
case "$1" in
    "auto")
        # Configuração automática (mesmo IP da interface principal)
        main_ip=$(ip addr show dev "$main_interface" | awk '/inet / {print $2}' | cut -d '/' -f 1)
        ;;
    "plusone")
        # Configuração com IP aumentado em 1 (maior que o IP da interface principal)
        main_ip=$(ip addr show dev "$main_interface" | awk '/inet / {split($2, a, "/"); print a[1]}')
        main_ip_last_octet=$(echo "$main_ip" | cut -d '.' -f 4)
        main_ip_last_octet_soma=$(expr 1 + $main_ip_last_octet)
        bridge_ip="192.168.15.$main_ip_last_octet_soma"
        ;;
    "interface")
        # Verifica se uma interface foi especificada
        if [ -z "$2" ]; then
            echo "Erro: Você deve especificar uma interface. Exemplo: $0 interface enp4s0"
            exibir_ajuda
        fi
        specified_interface="$2"
        main_ip=$(ip addr show dev "$specified_interface" | awk '/inet / {split($2, a, "/"); print a[1]}')
        bridge_ip="$main_ip"
        ;;
    "delete")
        # Exclui a rede bridge
        sudo nmcli connection delete br0
        sudo nmcli connection delete bridge0p1
        # Exiba as interfaces de rede
        sleep 2
        nmcli device status
        echo "Rede bridge excluída."
        exit 0
        ;;
    *)
        # Opção inválida ou ausente
        exibir_ajuda
        ;;
esac

# Cria uma bridge chamada "br0"
sudo nmcli connection add type bridge con-name br0 ifname br0

# Adiciona as interfaces físicas à bridge
for iface in $interfaces; do
    sudo nmcli connection add type ethernet slave-type bridge con-name bridge0p1 ifname "$iface" master br0
done

# Configura o IP fixo para a bridge
sudo nmcli connection modify br0 ipv4.addresses "$bridge_ip/24"
sudo nmcli connection modify br0 ipv4.method manual

# Ativa a bridge
sudo nmcli connection up br0

# Exiba as interfaces de rede
nmcli device status

echo "Configuração da bridge concluída!"
