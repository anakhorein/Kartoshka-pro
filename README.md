# Kartoshka Pro

Kartoshka Pro - это iOS приложение для отслеживания питания и анализа пищевой ценности продуктов. Приложение позволяет пользователям искать продукты, просматривать их пищевую ценность и вести учет своего питания.

## Основные возможности

- 🔍 Поиск продуктов по базе данных
- 📊 Детальная информация о пищевой ценности продуктов
- 🏷️ Категоризация продуктов
- 📱 Современный и удобный интерфейс
- 🔄 Кэширование данных для офлайн-доступа

## Технические детали

### Архитектура
- MVVM (Model-View-ViewModel)
- SwiftUI для пользовательского интерфейса
- Combine для реактивного программирования

### Структура проекта
```
Kartoshka pro/
├── Models/         # Модели данных
├── Views/          # SwiftUI представления
├── ViewModels/     # ViewModels для MVVM
├── Extensions/     # Расширения Swift
├── Config.swift    # Конфигурация приложения
└── Assets.xcassets # Ресурсы приложения
```

### API
Приложение использует REST API для получения данных о продуктах:
- Базовый URL: `https://api.knyazev.site`
- Эндпоинты:
  - `/food/` - список продуктов
  - `/food/item` - детальная информация о продукте

## Требования

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/yourusername/Kartoshka-pro.git
```

2. Откройте проект в Xcode:
```bash
cd Kartoshka-pro
open "Kartoshka pro.xcodeproj"
```

3. Соберите и запустите проект (⌘R)

## Лицензия

Этот проект распространяется под лицензией MIT. Подробности смотрите в файле LICENSE.

## Контакты

Александр Князев - [@your_twitter](https://twitter.com/your_twitter)

Проект доступен по адресу: [https://github.com/yourusername/Kartoshka-pro](https://github.com/yourusername/Kartoshka-pro) 