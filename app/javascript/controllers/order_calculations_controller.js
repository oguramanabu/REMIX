import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "purchasePrice", "sellPrice", "exchangeRate", 
                   "totalPurchaseAmount", "totalSalesAmount", "grossProfitAmount", "grossProfitPercentage"]

  connect() {
    this.updateCalculations()
  }

  updateCalculations() {
    // Check if all required targets exist
    if (!this.hasQuantityTarget || !this.hasPurchasePriceTarget || 
        !this.hasSellPriceTarget || !this.hasExchangeRateTarget) {
      return
    }

    const quantity = parseFloat(this.quantityTarget.value) || 0
    const purchasePrice = parseFloat(this.purchasePriceTarget.value) || 0
    const sellPrice = parseFloat(this.sellPriceTarget.value) || 0
    const exchangeRate = parseFloat(this.exchangeRateTarget.value) || 0
    
    // 仕入総額 = 数量 * 仕入単価 * 為替レート
    const totalPurchaseAmount = quantity * purchasePrice * exchangeRate
    this.totalPurchaseAmountTarget.textContent = 
      '¥' + new Intl.NumberFormat('ja-JP').format(totalPurchaseAmount)
    
    // 売上総額 = 数量 * 販売単価
    const totalSalesAmount = quantity * sellPrice
    this.totalSalesAmountTarget.textContent = 
      '¥' + new Intl.NumberFormat('ja-JP').format(totalSalesAmount)
    
    // 粗利 = 売上総額 - 仕入総額
    const grossProfitAmount = totalSalesAmount - totalPurchaseAmount
    this.grossProfitAmountTarget.textContent = 
      '¥' + new Intl.NumberFormat('ja-JP').format(grossProfitAmount)
    
    // 粗利率 = 粗利 / 売上総額 * 100
    const grossProfitPercentage = totalSalesAmount !== 0 
      ? ((grossProfitAmount / totalSalesAmount) * 100)
      : 0
    this.grossProfitPercentageTarget.textContent = 
      grossProfitPercentage.toFixed(2) + '%'
  }
}
