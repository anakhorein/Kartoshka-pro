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
        // Ждем загрузки данных
        let loadingIndicator = app.progressIndicators["Loading products"]
        if loadingIndicator.exists {
            // Ждем, пока индикатор загрузки исчезнет
            let loadingDisappeared = NSPredicate(format: "exists == false")
            expectation(for: loadingDisappeared, evaluatedWith: loadingIndicator)
            waitForExpectations(timeout: 10)
        }
        
        // Находим и тапаем на первый элемент в списке
        let firstFoodItem = app.otherElements.matching(identifier: "foodItem").firstMatch
        XCTAssertTrue(firstFoodItem.exists, "Не найден элемент списка")
        firstFoodItem.tap()
        
        // Проверяем, что мы перешли на экран деталей
        let detailView = app.navigationBars.firstMatch
        XCTAssertTrue(detailView.exists)
        
        // Проверяем наличие кнопки возврата
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists)
    }
    
    func testDetailViewContent() throws {
        // Ждем загрузки данных
        let loadingIndicator = app.progressIndicators["Loading products"]
        if loadingIndicator.exists {
            let loadingDisappeared = NSPredicate(format: "exists == false")
            expectation(for: loadingDisappeared, evaluatedWith: loadingIndicator)
            waitForExpectations(timeout: 10)
        }
        
        // Переходим на экран деталей
        let firstFoodItem = app.otherElements.matching(identifier: "foodItem").firstMatch
        firstFoodItem.tap()
        
        // Проверяем наличие основных элементов на экране деталей
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)
    }
} 