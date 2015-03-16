require 'test_helper'

class Admin::Vendor::ProductsControllerTest < ActionController::TestCase
  setup do
    @admin_vendor_product = admin_vendor_products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_vendor_products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_vendor_product" do
    assert_difference('Admin::Vendor::Product.count') do
      post :create, admin_vendor_product: {  }
    end

    assert_redirected_to admin_vendor_product_path(assigns(:admin_vendor_product))
  end

  test "should show admin_vendor_product" do
    get :show, id: @admin_vendor_product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_vendor_product
    assert_response :success
  end

  test "should update admin_vendor_product" do
    patch :update, id: @admin_vendor_product, admin_vendor_product: {  }
    assert_redirected_to admin_vendor_product_path(assigns(:admin_vendor_product))
  end

  test "should destroy admin_vendor_product" do
    assert_difference('Admin::Vendor::Product.count', -1) do
      delete :destroy, id: @admin_vendor_product
    end

    assert_redirected_to admin_vendor_products_path
  end
end
