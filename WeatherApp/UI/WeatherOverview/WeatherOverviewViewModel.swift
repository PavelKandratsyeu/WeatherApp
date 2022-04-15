//
//  WeatherOverviewViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kondratyev on 14.04.22.
//

import Foundation


protocol WeatherOverviewViewModelDelegate {

  func openWeatherDetails(with context: HourlyWeatherContext)
}


class WeatherOverviewViewModel: WeatherOverviewViewControllerDelegate, ListenableSupport, DailyWeatherDataListener {

  typealias Injector = DailyWeatherDataManagerProvider

  private let injector: Injector
  private let coordinator: WeatherOverviewViewModelDelegate
  private let dailyWeatherDataManager: DailyWeatherDataManagerProtocol
  var listeners: Set<AnyWeakHashedWrapper> = []

  init(injector: Injector, coordinator: WeatherOverviewViewModelDelegate) {
    self.injector = injector
    self.coordinator = coordinator
    let context = DailyWeatherContext(
      location: WeatherLocation(latitude: 52.5235, longitude: 13.4115),
      timezone: .current
    )
    self.dailyWeatherDataManager = injector.getDailyWeatherDataManager(context: context)

    dailyWeatherDataManager.addListener(self)
  }

  // MARK: - WeatherOverviewViewControllerDelegate

  var dailyWeather: [DayWeather?] { dailyWeatherDataManager.dailyWeather }

  func refetchDataIfNeeded() {
    dailyWeatherDataManager.refetchDataIfNeeded()
  }

  func openDay(index: Int) {
    let hourlyContext = dailyWeatherDataManager.getHourlyWeatherContext(index: index)
    coordinator.openWeatherDetails(with: hourlyContext)
  }

  // MARK: - DailyWeatherDataListener

  func dailyWeatherChanged() {
    notifyDailyWeatherChanged()
  }
}


// MARK: - Private
private extension WeatherOverviewViewModel {

  func notifyDailyWeatherChanged() {
    enumerateListeners { ($0 as? WeatherOverviewViewControllerDelegateListener)?.dailyWeatherChanged() }
  }
}
