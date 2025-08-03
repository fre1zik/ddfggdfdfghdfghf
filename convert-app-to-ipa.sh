#!/bin/bash

# Convert .app to .ipa script
# Автор: AI Assistant
# Версия: 1.0

echo "📱 .app to .ipa Converter"
echo "========================="

# Проверяем наличие .app файла
APP_PATH="build/ios/Debug-iphoneos/Runner.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ .app file not found at: $APP_PATH"
    echo "   First build the app: flutter build ios --debug --no-codesign"
    exit 1
fi

echo "✅ Found .app file: $APP_PATH"

# Создаем временную папку
TEMP_DIR="temp_ipa_build"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/Payload"

echo "📦 Creating IPA structure..."

# Копируем .app в Payload
cp -r "$APP_PATH" "$TEMP_DIR/Payload/"

# Создаем .ipa файл
cd "$TEMP_DIR"
zip -r ../telegram-client.ipa Payload
cd ..

echo "✅ IPA file created: telegram-client.ipa"

# Очищаем временные файлы
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Conversion completed!"
echo "📱 IPA file: telegram-client.ipa"
echo ""
echo "📋 Installation options:"
echo "   1. AltStore (recommended)"
echo "   2. Sideloadly"
echo "   3. 3uTools"
echo "   4. Manual installation via iTunes/Finder"
echo ""
echo "⚠️  Note: You may need to trust the developer in:"
echo "   Settings → General → Device Management" 