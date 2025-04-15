import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NAT_ProductCard extends NavigationMixin(LightningElement) {
  @api product;

  get name() {
    return this.product?.Name;
  }

  get category() {
    return this.product?.NAT_Category__c;
  }

  get brand() {
    return this.product?.NAT_Brand__c;
  }

  get price() {
    return this.product?.NAT_Price__c;
  }

  get stock() {
    return this.product?.NAT_Stock__c;
  }

  get thumbnail() {
    return this.product?.NAT_ThumbnailURL__c;
  }

  navigateToRecord() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.product?.Id,
        objectApiName: 'Product2',
        actionName: 'view'
      }
    });
  }
}
