//
//  ContentView.swift
//  Corona
//
//  Created by 五十嵐伸雄 on 2020/03/22.
//  Copyright © 2020 五十嵐伸雄. All rights reserved.
//

import SwiftUI

struct TimeSeries: Decodable {
    let US: [DayData]
    let Japan: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}

class ChartViewModel: ObservableObject {
    
    @Published var dataSet = [DayData]()
    var max = 0
    
    init() {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            //            print(data)
            
            guard let data = data else { return }
            do {
                let timeSeries = try JSONDecoder().decode(TimeSeries.self, from: data)
                
                
                DispatchQueue.main.async {
                    self.dataSet = timeSeries.Japan
                    self.max = self.dataSet.max(by: {(day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                        })?.deaths ?? 0
                }
                
                timeSeries.Japan.forEach { (dayData) in
                    print(dayData.date, dayData.confirmed, dayData.deaths)
                }
                
            } catch {
                print("JSON DECODE failed:", error)
            }
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var vm = ChartViewModel()
    
    var body: some View {
        VStack{
            Text("コロナ").font(.system(size: 34, weight: .bold))
            Text("合計死者")
            if !vm.dataSet.isEmpty {
                ScrollView(.horizontal) {
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(vm.dataSet, id: \.self) { day in
                            HStack (spacing: 4){
                                Spacer()
                                Text(day.date)
                            }.frame(width: 8, height: (CGFloat(day.deaths) / CGFloat(self.vm.max)) * 200)
                                .background(Color.red)
                        }
                    }
                }
            }
//            HStack{
//                VStack{
//                    Spacer()
//                }.frame(width: 10, height: 200)
//                    .background(Color.red)
//                VStack{
//                    Spacer()
//                }.frame(width: 10, height: 200)
//                    .background(Color.red)
//                VStack{
//                    Spacer()
//                }.frame(width: 10, height: 200)
//                    .background(Color.red)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
