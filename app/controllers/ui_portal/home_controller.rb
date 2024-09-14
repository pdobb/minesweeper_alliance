# frozen_string_literal: true

class UIPortal::HomeController < UIPortal::BaseController
  def show
    Layouts::Flash::TYPES.each do |type|
      flash.now[type] = [
        "Test #{type}",
        {
          text:
            "Test #{type} w/ no Auto-Timeout and with E X T R A content.",
          timeout: false,
        },
      ]
    end
  end
end
