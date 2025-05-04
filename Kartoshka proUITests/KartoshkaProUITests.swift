//
//  KartoshkaProUITests.swift
//  Kartoshka pro
//
//  Created by Alexander Knyazev on 04.05.2025.
//


import XCTest

final class KartoshkaProUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testContentViewInitialState() throws {
        // Проверяем, что приложение запустилось
        XCTAssertTrue(app.exists)
        
        // Проверяем наличие основных элементов интерфейса
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.exists)
        
        // Проверяем наличие поисковой строки
        let searchField = app.textFields["Search (min 3 symbols)"]
        XCTAssertTrue(searchField.exists)
    }
    
    func testDetailViewNavigation() throws {
        // Проверяем начальное состояние
        XCTAssertTrue(app.exists, "Приложение не запустилось")
        
        // Проверяем наличие индикатора загрузки
        let loadingIndicator = app.progressIndicators["Loading products"]
        print("Индикатор загрузки существует: \(loadingIndicator.exists)")
        
        if loadingIndicator.exists {
            print("Ожидание завершения загрузки...")
            let loadingDisappeared = NSPredicate(format: "exists == false")
            expectation(for: loadingDisappeared, evaluatedWith: loadingIndicator)
            waitForExpectations(timeout: 10)
            print("Загрузка завершена")
        }
        
        // Проверяем наличие основных элементов интерфейса
        print("Проверка элементов интерфейса:")
        print("Navigation bar exists: \(app.navigationBars.firstMatch.exists)")
        print("Search field exists: \(app.textFields["Search (min 3 symbols)"].exists)")
        print("Other elements count: \(app.otherElements.count)")
        
        // Ждем появления элементов списка
        let listItems = app.otherElements.matching(identifier: "foodItem")
        print("Количество элементов списка: \(listItems.count)")
        
        // Проверяем все элементы интерфейса
        print("Все элементы интерфейса:")
        //for element in app.otherElements.allElementsBoundByIndex {
            //print("Element: \(element.identifier), exists: \(element.exists)")
        //}
        
        // Ждем появления элементов списка с более длительным таймаутом
        let listItemsExist = NSPredicate(format: "count > 0")
        expectation(for: listItemsExist, evaluatedWith: listItems)
        waitForExpectations(timeout: 20)
        
        // Проверяем, что список не пустой
        XCTAssertGreaterThan(listItems.count, 0, "Список продуктов пуст")
        
        // Выбираем первый элемент
        let firstItem = listItems.element(boundBy: 0)
        print("Первый элемент существует: \(firstItem.exists)")
        firstItem.tap()
        
        // Проверяем переход на экран деталей
        let detailNavigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(detailNavigationBar.exists, "Навигационная панель детального экрана не найдена")
        
        // Проверяем наличие кнопки возврата
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists, "Кнопка возврата не найдена")
    }
    
    func testDetailViewContent() throws {
        // Проверяем начальное состояние
        XCTAssertTrue(app.exists, "Приложение не запустилось")
        
        // Проверяем наличие индикатора загрузки
        let loadingIndicator = app.progressIndicators["Loading products"]
        print("Индикатор загрузки существует: \(loadingIndicator.exists)")
        
        if loadingIndicator.exists {
            print("Ожидание завершения загрузки...")
            let loadingDisappeared = NSPredicate(format: "exists == false")
            expectation(for: loadingDisappeared, evaluatedWith: loadingIndicator)
            waitForExpectations(timeout: 10)
            print("Загрузка завершена")
        }
        
        // Ждем появления элементов списка
        let listItems = app.otherElements.matching(identifier: "foodItem")
        print("Количество элементов списка: \(listItems.count)")
        
        // Ждем появления элементов списка с более длительным таймаутом
        let listItemsExist = NSPredicate(format: "count > 0")
        expectation(for: listItemsExist, evaluatedWith: listItems)
        waitForExpectations(timeout: 20)
        
        // Выбираем первый элемент
        let firstItem = listItems.element(boundBy: 0)
        print("Первый элемент существует: \(firstItem.exists)")
        firstItem.press(forDuration: 1.5)
        
        // Ждем загрузки данных на экране деталей
        let detailLoadingIndicator = app.progressIndicators["Loading info"]
        if detailLoadingIndicator.exists {
            print("Ожидание завершения загрузки деталей...")
            let detailLoadingDisappeared = NSPredicate(format: "exists == false")
            expectation(for: detailLoadingDisappeared, evaluatedWith: detailLoadingIndicator)
            waitForExpectations(timeout: 10)
            print("Загрузка деталей завершена")
        }
        
        // Проверяем наличие основных элементов на экране деталей
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists, "ScrollView не найден")
        
        // Выводим отладочную информацию о всех элементах
        /*print("Все элементы на экране:")
        let allElements = app.descendants(matching: .any)
        for i in 0..<allElements.count {
            let element = allElements.element(boundBy: i)
            print("Element: \(element.identifier), exists: \(element.exists), isEnabled: \(element.isEnabled)")
        }*/
        
        // Ждем появления заголовка
        print("Поиск заголовка...")
        let title = app.staticTexts["foodTitle"]
        print("Заголовок найден: \(title.exists)")
        
        // Проверяем наличие заголовка в разных контекстах
        let titleInScrollView = scrollView.staticTexts["foodTitle"]
        print("Заголовок в ScrollView: \(titleInScrollView.exists)")
        
        let titleByIdentifier = app.staticTexts.matching(identifier: "foodTitle").firstMatch
        print("Заголовок по идентификатору: \(titleByIdentifier.exists)")
        
        // Ждем появления заголовка с увеличенным таймаутом
        let titleExists = NSPredicate(format: "exists == true")
        expectation(for: titleExists, evaluatedWith: title)
        waitForExpectations(timeout: 20)
        XCTAssertTrue(title.exists, "Заголовок не найден")
        
        // Проверяем наличие информации о продукте
        let fdcId = app.staticTexts.matching(identifier: "fdcId").firstMatch
        XCTAssertTrue(fdcId.exists, "FDC ID не найден")
        
        // Проверяем наличие даты публикации
        let publicationDate = app.staticTexts.matching(identifier: "publicationDate").firstMatch
        XCTAssertTrue(publicationDate.exists, "Дата публикации не найдена")
        
    }
} 
