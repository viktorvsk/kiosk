require 'test_helper'

class Admin::Vendor::MerchantsControllerTest < ActionController::TestCase
  setup do
    @admin_vendor_merchant = admin_vendor_merchants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_vendor_merchants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_vendor_merchant" do
    assert_difference('Admin::Vendor::Merchant.count') do
      post :create, admin_vendor_merchant: {  }
    end

    assert_redirected_to admin_vendor_merchant_path(assigns(:admin_vendor_merchant))
  end

  test "should show admin_vendor_merchant" do
    get :show, id: @admin_vendor_merchant
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_vendor_merchant
    assert_response :success
  end

  test "should update admin_vendor_merchant" do
    patch :update, id: @admin_vendor_merchant, admin_vendor_merchant: {  }
    assert_redirected_to admin_vendor_merchant_path(assigns(:admin_vendor_merchant))
  end

  test "should destroy admin_vendor_merchant" do
    assert_difference('Admin::Vendor::Merchant.count', -1) do
      delete :destroy, id: @admin_vendor_merchant
    end

    assert_redirected_to admin_vendor_merchants_path
  end
end
