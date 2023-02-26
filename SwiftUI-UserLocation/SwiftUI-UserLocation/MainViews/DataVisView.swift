//
//  DataVisView.swift
//  SwiftUI-UserLocation
//
//  Created by 赵松言 on 2/26/23.
//

import SwiftUI
import SwiftUICharts

struct DataVisView: View {
    var body: some View {
        BarChartView(data: ChartData(values: [("James",21), ("Anderson",10), ("library",5), ("Sayles",5), ("LDC",5)]), title: "Top 5 location",legend: "counts",form: ChartForm.medium, animatedToBack:true) // legend is optional
    }
}

struct DataVisView_Previews: PreviewProvider {
    static var previews: some View {
        DataVisView()
    }
}
