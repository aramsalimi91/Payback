require 'spec_helper'

describe User do

	before do
		@user = User.new(
      full_name: "John Smith",
      email: "user@example.com",
      password: "12345",
      password_confirmation: "12345"
    )
	end

  subject { @user }
  
  it { should respond_to(:full_name) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  describe "when full name is not present" do
  	before { @user.full_name = "" }
  	it { should_not be_valid }
  end

  describe "when full name is too long" do
  	before { @user.full_name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do    
    invalid_addresses =  %w[ user@foo,com user_at_foo.org example.user@foo. ]

    invalid_addresses.each do |invalid_address|
      before { @user.email = invalid_address }
      it { should_not be_valid }
    end
  end

  describe "when email format is valid" do
    valid_addresses = %w[ user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn ]
    valid_addresses.each do |valid_address|
      before { @user.email = valid_address }
      it { should be_valid }
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 4 }
    it { should be_invalid }
  end

  describe "auth token" do
    before { @user.save }
    its(:auth_token) { should_not be_blank }
  end

end
