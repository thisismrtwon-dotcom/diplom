function log {
   echo -e "\e[0;32m$1\e[0m"
}
cd /root
log "Обновление и установка пакетов..."
sudo apt update && sudo apt install -y wget curl unzip
wget https://hashicorp-releases.yandexcloud.net/terraform/1.9.2/terraform_1.9.2_linux_amd64.zip && sudo unzip terraform_1.9.2_linux_amd64.zip -d /usr/bin
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
sudo cp ./yandex-cloud/bin/* /usr/bin/
log "Авторизация на yandex cloud..."
yc init
log "Создание .terraformrc"
cat > ~/.terraformrc << EOF
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
EOF

read -p "Введите ID сервисного аккаунта: " service_acc_id
read -p "Введите ID облака: " cloud_id
read -p "Введите ID каталога: " folder_id
read -p "Придумайте имя профиля: " profile_name_id

yc iam key create --service-account-id $service_acc_id --folder-name default --output key.json

yc config profile create $profile_name_id
yc config set service-account-key key.json
yc config set cloud-id $cloud_id
yc config set folder-id $folder_id

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

log "Установка и инциализация завершена..."

log "Настройка providers.tf"
mkdir ~/terraform_yandex && cd ~/terraform_yandex
touch providers.tf
cat > providers.tf << EOF
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}
EOF

terraform init

log "настройка terraform.tfvars"
cat > terraform.tfvars << EOF
virtual_machines = {
    "server-nginx-balancer" = {
      vm_name      = "server-nginx-balancer" # Имя ВМ
      vm_desc      = "Балансировка нагрузки на MediaWiki" # Описание
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-nginx-balancer" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    },
    "server-nginx-1" = {
      vm_name      = "server-nginx-1" # Имя ВМ
      vm_desc      = "1 Nginx сервер MediaWiki"
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-nginx-1" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    },
     "server-nginx-2" = {
      vm_name      = "server-nginx-2" # Имя ВМ
      vm_desc      = "2 Nginx сервер MediaWiki"
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-nginx-2" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    },
     "server-postgresql-master" = {
      vm_name      = "server-postgresql-master" # Имя ВМ
      vm_desc      = "Главный мастер сервер postgresql"
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-postgresql-master" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    },
     "server-postgresql-replica" = {
      vm_name      = "server-postgresql-replica" # Имя ВМ
      vm_desc      = "Реплика для master сервера postgresql"
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-postgresql-replica" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    },
     "server-backup" = {
      vm_name      = "server-backup" # Имя ВМ
      vm_desc      = "Бекап сервер для файлов сервера nginx и данных postgresql"
      vm_cpu       = 2 # Кол-во ядер процессора
      ram          = 2 # Оперативная память в ГБ
      disk         = 20 # Объём диска в ГБ
      disk_name    = "ubuntu2204-server-backup" # Название диска
      template     = "fd81no7ub0p1nooono37" # ID образа ОС для использования
    }
}
EOF

log "настройка main.tf"
cat > main.tf << "EOF"
resource "yandex_compute_disk" "boot-disk" {
  for_each = var.virtual_machines
  name     = each.value["disk_name"]
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = each.value["disk"]
  image_id = each.value["template"]
}

resource "yandex_vpc_network" "mediawiki-network-1" {
  name = "mediawiki-network-1"
}

resource "yandex_vpc_subnet" "subnet-mediawiki-1" {
name = "subnet1"
zone = "ru-central1-a"
network_id = yandex_vpc_network.mediawiki-network-1.id
v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "virtual_machine" {
  metadata = {
     ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
   } 
  for_each        = var.virtual_machines
  name = each.value["vm_name"]

  resources {
    cores  = each.value["vm_cpu"]
    memory = each.value["ram"]
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-mediawiki-1.id
    nat       = true
  }
}
EOF

log "настройка variables.tf"
touch variables.tf
cat > variables.tf << EOF
variable "virtual_machines" {
 default = ""
}
EOF

log "настройка output.tf"
touch output.tf
cat > output.tf << EOF
output "vm_ip" {
  value = { for k, v in  yandex_compute_instance.virtual_machine : k => v.network_interface.0.ip_address }
}

output "vm_nat_ip" {
  value = { for k, v in  yandex_compute_instance.virtual_machine : k => v.network_interface.0.nat_ip_address}
}
EOF

log "Создаем ssh ключ..."
cd /root/.ssh
ssh-keygen -t ed25519

cd /root/terraform_yandex

log "Валидация конфигурации terraform..."
terraform validate

log  "Выводим план действий..."
terraform plan

read -p "Создать инфраструктуру? (y/n): " access
if [[ $access == "y" ]]; then
  terraform apply -auto-approve
fi

echo "Конец."
