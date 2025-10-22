BACKUP_IP="{{ hostvars['backup-server']['ansible_local'] }}" #ip адрес backup сервера
BACKUP_USER="{{ hostvars['backup-server']['ansible_backup_user'] }}" #пользователь на backup сервере
BACKUP_PASSWORD="{{ hostvars['backup-server']['ansible_backup_password'] }}" #пароль для пользователя
DIRECTORY_FOR_BACKUP=$1 #директория для резервного копирования
PREFIX_BACKUP_FILE=$(cat /etc/hostname)  #название машины, будет использоваться как префикс к backup файлу
CURRENT_TIME=$(date +"%d_%m_%Y__%H-%M-%S") #текущее время в формате  день_месяц_год__час-минута-секунда
RESULT_FILENAME="$PREFIX_BACKUP_FILE"-"$CURRENT_TIME".tar.gz #итоговое название архива
DIRECTORY_FOR_SAVE_TAR=$HOME  #директория для временного сохранения архива на этой машине
FULL_PATH="$HOME"/"$RESULT_FILENAME"  #полный путь до backup архива на этой машине

function ping_check_backup_host { #проверка доступности хоста
   if ping -c 1 -W 2 "$BACKUP_IP" &> /dev/null; then
      echo "backup сервер $BACKUP_IP доступен"
   else
      echo "backup сервер $BACKUP_IP не доступен"
      exit
   fi
}

function create_backup_file {  #создание архива
   result_save_file="$HOME/$RESULT_FILENAME"
   if tar -czf $result_save_file $DIRECTORY_FOR_BACKUP; then
      echo "архив $result_save_file" успешно создан
   else
      echo "не удалось создать архив, возможно директория не существует."
      exit
   fi
}

function send_file_to_backup_server {  #отправка архива на backup сервер
   if sshpass -p "$BACKUP_PASSWORD" scp -o StrictHostKeyChecking=no $FULL_PATH "$BACKUP_USER@$BACKUP_IP:~"; then
      echo "файл успешно сохранен на backup сервере."
   else
      echo "ошибка при передаче архива на сервер."
   fi
}

function delete_old_file {  #удаление не нужного архива
   if rm $FULL_PATH; then
      echo "не нужный архив успешно удален"
   else
      echo "ошибка при удалении архива с данной машины"
      exit
   fi
}

function main {  #главная функция для последовательного вызова функций
  ping_check_backup_host
  create_backup_file
  send_file_to_backup_server
  delete_old_file
}

main
