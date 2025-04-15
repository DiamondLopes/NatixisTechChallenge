import { LightningElement, track } from 'lwc';
import getProducts from '@salesforce/apex/NAT_ProductSyncController.getProducts';
import refreshProductData from '@salesforce/apex/NAT_ProductSyncController.refreshProductData';

export default class NatProductVisualizer extends LightningElement {

  /*
   * Variables
   */

  products = [];
  currentPageProducts = []; 
  currentPage = 1; 
  productsPerPage = 12; 
  pageStockTotal = 0;
  stockTotal = 0;
  pageInStockTotal = 0;
  inStockTotal = 0;
  isLoading = true;
  hasProducts = false;

  // Filter variables
  nameFilter = '';
  categoryFilter = '';
  brandFilter = '';

  categoryOptions = [{
    label: 'All',
    value: ''
  }];
  brandOptions = [{
    label: 'All',
    value: ''
  }] 

  
  /*
   * Product data management
   */

  // Load products when the component is created
  connectedCallback() {
    this.getProducts(); 
  }

  getProducts() {
    this.isLoading = true;
    getProducts().then((result) => {
        this.products = result; 
        this.updateFilterOptions();
        this.updatePageProducts();
        this.calcStockValues();
        this.currentPage = 1;
        this.isLoading = false;
      }).catch((error) => {
        console.error('Error fetching products:', error);
      });
  }

  
  // Refresh the product list
  refreshProductData() {
    this.isLoading = true;
    refreshProductData().then(() => {
        this.getProducts();
        console.log('Product data successfully refreshed');
      }).catch((error) => {
        console.error('Error refreshing product data:', error);
      });
  }

  get foundProducts(){
    return (this.currentPageProducts && this.currentPageProducts.length > 0);
  }

  // Update category and brand filter options based on the fetched products
  updateFilterOptions() {

    const categories = new Set();
    const brands = new Set();

    
    categories.add('All');
    brands.add('All');
  
    //Fill cetegory and brand options
    this.products.forEach((product) => {
      categories.add(product.NAT_Category__c);
      brands.add(product.NAT_Brand__c);
    });
    
    this.categoryOptions = [...categories].map((category) => (
      category == 'All'? {
        label: category,
        value: ''
      } : {
        label: category,
        value: category
    }));
    this.brandOptions = [...brands].map((brand) => (
      brand == 'All'? {
        label: brand,
        value: ''
      } : {
        label: brand,
        value: brand
    }));
  }

  // Filter products based on the selected filters
  get filteredProducts() {
    return this.products.filter((product) => {
      return (
        (this.nameFilter ? (product.Name && product.Name.toLowerCase().includes(this.nameFilter.toLowerCase())) : true) &&
        (this.categoryFilter ? (product.NAT_Category__c && product.NAT_Category__c.toLowerCase().includes(this.categoryFilter.toLowerCase())) : true) &&
        (this.brandFilter ? (product.NAT_Brand__c && product.NAT_Brand__c.toLowerCase().includes(this.brandFilter.toLowerCase())) : true)
      );
    });
  }

 /*
   * Stock
   */

 calcStockValues(){
  this.stockTotal = 0;
  this.pageStockTotal = 0;
  this.inStockTotal = 0;
  this.pageInStockTotal = 0;
  if(this.products){
    this.products.map((product) => {
      this.stockTotal += product.NAT_Stock__c;
      if(product.NAT_Stock__c > 0){
        this.inStockTotal++;
      }
    })
  }
  if(this.currentPageProducts){
    this.currentPageProducts.map((product) => {
      this.pageStockTotal += product.NAT_Stock__c;
      if(product.NAT_Stock__c > 0){
        this.pageInStockTotal++;
      }
    })
  }
 }


  /*
   * Pagination controls
   */

   
  get totalPages() {
    return Math.ceil(this.filteredProducts.length / this.productsPerPage);
  }

  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage === this.totalPages;
  }

  // Update the products shown on the current page
  updatePageProducts() {
    const startIndex = (this.currentPage - 1) * this.productsPerPage;
    const endIndex = startIndex + this.productsPerPage;
    this.currentPageProducts = this.filteredProducts.slice(startIndex, endIndex);
    this.calcStockValues();
  }

  // Handle name filter change
  handleNameFilterChange(event) {
    this.nameFilter = event.target.value;
    this.currentPage = 1; 
    this.updatePageProducts();
  }

  // Handle category filter change
  handleCategoryFilterChange(event) {
    this.categoryFilter = event.target.value;
    this.currentPage = 1; 
    this.updatePageProducts();
  }

  // Handle brand filter change
  handleBrandFilterChange(event) {
    this.brandFilter = event.target.value;
    this.currentPage = 1; 
    this.updatePageProducts();
  }

  // Handle next page click
  handleNext() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.updatePageProducts();
    }
  }

  // Handle previous page click
  handlePrevious() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.updatePageProducts();
    }
  }
}