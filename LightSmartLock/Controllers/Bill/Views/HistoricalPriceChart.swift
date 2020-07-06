//
//  HistoricalPriceChart.swift
//  LightSmartLock
//
//  Created by mugua on 2020/7/6.
//  Copyright © 2020 mugua. All rights reserved.
//

import UIKit
import Charts

class HistoricalPriceChart: UIView {
    
    private lazy var chartView: LineChartView = {
        let chart = LineChartView(frame: .zero)
        chart.delegate = self
        return chart
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "历史均价"
        label.textColor = ColorClassification.textPrimary.value
        return label
    }()
    
    private lazy var dotViewStackContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(UIImageView(image: UIImage(named: "chart_smae_community")))
        let l1 = UILabel()
        l1.textColor = ColorClassification.textOpaque78.value
        l1.font = UIFont.systemFont(ofSize: 12)
        l1.text = "同小区"
        l1.sizeToFit()
        stackView.addArrangedSubview(l1)
        stackView.addArrangedSubview(UIImageView(image: UIImage(named: "chart_same_city")))
        let l2 = UILabel()
        l2.textColor = ColorClassification.textOpaque78.value
        l2.font = UIFont.systemFont(ofSize: 12)
        l2.sizeToFit()
        l2.text = "同城区"
        stackView.addArrangedSubview(l2)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(8)
            maker.top.equalToSuperview().offset(20)
        }
        
        dotViewStackContainer.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-8)
            maker.top.equalToSuperview().offset(20)
        }
        
        chartView.snp.makeConstraints { (maker) in
            maker.top.equalTo(titleLabel.snp.bottom).offset(20)
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func commonInit() {
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerTapEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.gridBackgroundColor = UIColor.white
        chartView.legend.enabled = false
        /// 图例
        let l = chartView.legend
        l.form = .circle
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = ColorClassification.textDescription.value
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        
        /// X 轴
        let xAxis = chartView.xAxis
        xAxis.labelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        xAxis.labelTextColor = UIColor(red: 0.024, green: 0.11, blue: 0.247, alpha: 0.4)
        xAxis.axisLineColor = ColorClassification.textDescription.value
        xAxis.axisLineWidth = 0.5
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = MonthFormatter()
        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5
        xAxis.granularity = 1
        /// Y 轴-左侧
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor(red: 0.024, green: 0.11, blue: 0.247, alpha: 0.4)
        leftAxis.labelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = ColorClassification.textDescription.value
        leftAxis.gridLineWidth = 0.5
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.valueFormatter = PriceFormatter()
        leftAxis.setLabelCount(5, force: true)
        
        /// Y 轴-右侧
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = UIColor(red: 0.024, green: 0.11, blue: 0.247, alpha: 0.4)
        rightAxis.labelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        rightAxis.drawAxisLineEnabled = false
        rightAxis.gridColor = ColorClassification.textDescription.value
        rightAxis.gridLineWidth = 0.5
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 100
        rightAxis.valueFormatter = PriceFormatter()
        rightAxis.setLabelCount(5, force: true)
        
        chartView.animate(yAxisDuration: 0.8)
        
        self.addSubview(titleLabel)
        self.addSubview(chartView)
        self.addSubview(dotViewStackContainer)
    }
    
    func setupChartWhit(data: LineChartData?) {
        var yVals1: [ChartDataEntry] = []
        var yVals2: [ChartDataEntry] = []
        
        var colorVals: [ChartDataEntry] = []
        /// 用于处理跨年时间的月份处理，前提数据是按日期顺序排序的
        
        for model in 1..<7 {
            
            let month = Double(String(model)) ?? 0
            let entry1 = ChartDataEntry(x: month, y: Double(arc4random_uniform(UInt32(model)) * 15), data: model)
            entry1.icon = UIImage(named: "chart_same_city")
            yVals1.append(entry1)
            
            let entry2 = ChartDataEntry(x: month, y: Double(arc4random_uniform(UInt32(model)) * 8), data: model)
            entry2.icon = UIImage(named: "chart_smae_community")
            yVals2.append(entry2)
            
            colorVals.append(ChartDataEntry(x: month, y: Double(100)))
        }
        
        let set1 = LineChartDataSet(entries: yVals1, label: "同城区")
        set1.drawIconsEnabled = true
        set1.drawCirclesEnabled = false
        set1.drawCircleHoleEnabled = false
        set1.axisDependency = .left
        set1.lineWidth = 2
        set1.valueFont = UIFont.systemFont(ofSize: 0)
        
        let set2 = LineChartDataSet(entries: yVals2, label: "同小区")
        set2.axisDependency = .left
        set2.drawIconsEnabled = true
        set2.drawCirclesEnabled = false
        set2.drawCircleHoleEnabled = false
        set2.lineWidth = 2
        set2.valueFont = UIFont.systemFont(ofSize: 0)
        set2.setColor(#colorLiteral(red: 0.0431372549, green: 0.6901960784, blue: 0.4823529412, alpha: 0.6))
        
        /// 柱状背景条
        var sets: [LineChartDataSet] = []
        for i in 0..<(colorVals.count/2) {
            let entries = [colorVals[2*i],colorVals[2*i+1]]
            
            let set = LineChartDataSet(entries: entries,label: nil)
            set.axisDependency = .left
            set.lineWidth = 0
            set.setColor(.clear)
            set.valueTextColor = .clear
            
            let gradientColors = [#colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9098039216, alpha: 1).cgColor,
                                  #colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9098039216, alpha: 0.5).cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            
            set.fill = Fill(linearGradient: gradient, angle: 90)
            set.fillAlpha = 1
            set.drawFilledEnabled = true
            set.drawCirclesEnabled = false
            set.drawCircleHoleEnabled = false
            
            sets.append(set)
        }
        sets.append(contentsOf: [set1, set2])
        self.chartView.data = LineChartData(dataSets: sets)
        
    }
}

extension HistoricalPriceChart {
    
    class MonthFormatter: IAxisValueFormatter {
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            var month: UInt = 0
            if value < 1 {
                month = UInt(12 + value)
            } else if value < 13 && value > 0 {
                month = UInt(value)
            } else {
                month = UInt(value - 12)
            }
            return String(format: "%02D", month) + "月"
        }
    }
    
    class PriceFormatter: IAxisValueFormatter {
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if value > 0 {
                return String(format: "%2.f", value) + "万"
            }
            return String(format: "%2.f", value)
        }
    }
}

extension HistoricalPriceChart: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}
