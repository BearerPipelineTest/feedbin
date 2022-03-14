class AccountMigrationsController < ApplicationController
  def index
    @user = current_user
    @migration = @user.account_migrations.last

    respond_to do |format|
      format.js
      format.html do
        render layout: "settings"
      end
    end
  end
end
