#!/bin/bash

# Telegram Client Launcher Script
# Автор: AI Assistant
# Версия: 1.0

echo "🚀 Запуск Telegram Client..."

# Проверяем, что мы в правильной папке
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ошибка: pubspec.yaml не найден. Убедитесь, что вы в папке telegram_client"
    exit 1
fi

# Устанавливаем путь к Flutter
export PATH="$PATH:../flutter/bin"

# Проверяем Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Ошибка: Flutter не найден. Убедитесь, что Flutter установлен."
    exit 1
fi

echo "📦 Установка зависимостей..."
flutter pub get

# Определяем доступные устройства
echo "🔍 Поиск доступных устройств..."
flutter devices

echo ""
echo "Выберите платформу для запуска:"
echo "1) Web (Chrome)"
echo "2) Linux"
echo "3) Android (если подключен)"
echo "4) Показать все доступные устройства"

read -p "Введите номер (1-4): " choice

case $choice in
    1)
        echo "🌐 Запуск в Chrome..."
        flutter run -d chrome
        ;;
    2)
        echo "🐧 Запуск на Linux..."
        flutter run -d linux
        ;;
    3)
        echo "📱 Запуск на Android..."
        flutter run -d android
        ;;
    4)
        echo "📋 Доступные устройства:"
        flutter devices
        echo ""
        read -p "Введите ID устройства: " device_id
        flutter run -d $device_id
        ;;
    *)
        echo "❌ Неверный выбор. Запускаю в Chrome по умолчанию..."
        flutter run -d chrome
        ;;
esac 