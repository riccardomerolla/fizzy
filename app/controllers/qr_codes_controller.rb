class QrCodesController < ApplicationController
  allow_unauthenticated_access

  def show
    expires_in 1.year, public: true
    render svg: RQRCode::QRCode.new(QrCodeLink.from_signed(params[:id]).url).as_svg(viewbox: true, fill: :white, color: :black)
  end
end
