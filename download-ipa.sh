#!/bin/bash

# Telegram Client IPA Downloader
# Автор: AI Assistant
# Версия: 1.0

echo "📱 Telegram Client IPA Downloader"
echo "=================================="

# Проверяем наличие SSH ключа
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "❌ SSH ключ не найден. Создайте ключ:"
    echo "   ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
    exit 1
fi

# Настройки сервера (замените на ваши)
SSH_HOST="your-server.com"
SSH_USERNAME="your-username"
SSH_PORT="22"
REMOTE_PATH="/home/$SSH_USERNAME/telegram-client/"

echo "🔧 Настройки подключения:"
echo "   Сервер: $SSH_HOST"
echo "   Пользователь: $SSH_USERNAME"
echo "   Порт: $SSH_PORT"
echo "   Путь: $REMOTE_PATH"
echo ""

# Проверяем подключение к серверу
echo "🔍 Проверка подключения к серверу..."
if ! ssh -p $SSH_PORT -o ConnectTimeout=10 -o BatchMode=yes $SSH_USERNAME@$SSH_HOST exit 2>/dev/null; then
    echo "❌ Не удается подключиться к серверу"
    echo "   Проверьте:"
    echo "   - Правильность адреса сервера"
    echo "   - SSH ключ добавлен на сервер"
    echo "   - Порт SSH открыт"
    exit 1
fi

echo "✅ Подключение к серверу успешно"
echo ""

# Проверяем наличие IPA файлов на сервере
echo "🔍 Поиск IPA файлов на сервере..."
IPA_FILES=$(ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST "ls $REMOTE_PATH*.ipa 2>/dev/null")

if [ -z "$IPA_FILES" ]; then
    echo "❌ IPA файлы не найдены на сервере"
    echo "   Убедитесь, что GitHub Actions завершился успешно"
    exit 1
fi

echo "📁 Найденные IPA файлы:"
echo "$IPA_FILES"
echo ""

# Создаем папку для загрузок
DOWNLOAD_DIR="./downloads"
mkdir -p $DOWNLOAD_DIR

# Загружаем все IPA файлы
echo "⬇️  Загрузка IPA файлов..."
for ipa_file in $IPA_FILES; do
    filename=$(basename "$ipa_file")
    echo "   Загружаем: $filename"
    
    if scp -P $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$ipa_file" "$DOWNLOAD_DIR/"; then
        echo "   ✅ $filename загружен успешно"
    else
        echo "   ❌ Ошибка загрузки $filename"
    fi
done

echo ""
echo "🎉 Загрузка завершена!"
echo "📁 Файлы сохранены в: $DOWNLOAD_DIR/"
echo ""

# Показываем список загруженных файлов
echo "📋 Загруженные файлы:"
ls -la $DOWNLOAD_DIR/*.ipa 2>/dev/null || echo "   Нет файлов"

echo ""
echo "📱 Для установки на iOS устройство:"
echo "   1. Подключите устройство к компьютеру"
echo "   2. Откройте iTunes/Finder"
echo "   3. Перетащите IPA файл в iTunes/Finder"
echo "   4. Синхронизируйте устройство"
echo ""
echo "⚠️  Примечание: Для установки требуется:"
echo "   - Разрешить установку из неизвестных источников"
echo "   - Или использовать AltStore/Cydia Impactor" 