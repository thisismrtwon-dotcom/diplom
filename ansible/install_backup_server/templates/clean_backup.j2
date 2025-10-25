
#!/bin/bash


# Директория для очистки
BACKUP_DIR="/home/backup_user"


# Возраст файлов для удаления (в днях)
DAYS_OLD=7

# Логирование (опционально)
LOG_FILE="/var/log/cleanup_backup.log"


# Проверяем существование директории
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Ошибка: директория $BACKUP_DIR не существует!" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Начало очистки файлов старше $DAYS_OLD дней в $BACKUP_DIR" | tee -a "$LOG_FILE"


# Находим и удаляем файлы старше $DAYS_OLD дней
find "$BACKUP_DIR" -type f -mtime +$DAYS_OLD -print -exec rm {} \; 2>>"$LOG_FILE"


echo "Очистка завершена." | tee -a "$LOG_FILE"
