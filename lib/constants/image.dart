import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/assets.gen.dart';

class AppImages {
  AppImages._();

  static const String roundedLogo = 'https://i.imgur.com/9EsY2t6.png';

  /* <---- Homepage banner -----> */
  static const String homePageBanner = 'https://i.imgur.com/8hBIsS5.png';

  /* <---- Image used on unknown page -----> */
  static const String illustrations404 = 'https://i.imgur.com/SGTzEiC.png';

  /* <---- INTRO LOGIN BACKGROUND IMAGES -----> */
  static const String introBackground1 = 'https://i.imgur.com/YQ9twZx.png';
  static const String introBackground2 = 'https://i.imgur.com/3hgB1or.png';

  /* <---- ONBOARDING IMAGES -----> */
  static const String onboarding1 = 'https://i.imgur.com/X2G11k0.png';
  static const String onboarding2 = 'https://i.imgur.com/sMLlh1i.png';
  static const String onboarding3 = 'https://i.imgur.com/lHlOUT5.png';

  /* <---- Other Illustrations -----> */
  static const String numberVerfication = 'https://i.imgur.com/tCCmY3I.png';
  static const String verified = 'https://i.imgur.com/vF1jB6b.png';

  /* <---- Products Images -----> */
  static const String productDemo1 = "https://i.imgur.com/CGCyp1d.png";
  static const String productDemo2 = "https://i.imgur.com/AkzWQuJ.png";
  static const String productDemo3 = "https://i.imgur.com/J7mGZ12.png";
  static const String productDemo4 = "https://i.imgur.com/q9oF9Yq.png";
  static const String productDemo5 = "https://i.imgur.com/MsppAcx.png";
  static const String productDemo6 = "https://i.imgur.com/JfyZlnO.png";

  /* <---- Coupon Backgrounds -----> */
  static const List<String> couponBackgrounds = [
    'assets/images/coupon_background_1.png',
    'assets/images/coupon_background_2.png',
    'assets/images/coupon_background_3.png',
    'assets/images/coupon_background_4.png',
  ];
}


class AppIcons {
  AppIcons._();

  // Material Design Icons
  static const chevronRight = Icons.chevron_right;
  static const iconCheck = Icons.check;
  static const toolbarSettings = Icons.settings;
  static const settingsTheme = Icons.palette;

  // Custom Assets (from the Assets class)
  static final attachmentDoc = Assets.images.fileDoc.svg();
  static final attachmentPdf = Assets.images.filePdf.svg();
  static final attachmentChevronsRight = Assets.images.chevronsRight.svg();
  static final attachmentFavorite = Assets.images.iconStar.svg();
  static final attachmentFavoriteActive = Assets.images.iconStarActive.svg();
  static final attachmentGivewayOutline = Assets.images.givewayOutline.svg();
  static final attachmentGooglePay = Assets.images.googlePay.svg();
  static final attachmentHelpOutline = Assets.images.helpOutline.svg();
  static final attachmentHide = Assets.images.hide.svg();
  static final attachmentPhone = Assets.images.phone.svg();
  static final attachmentTripOutline = Assets.images.tripOutline.svg();
  static final attachmentTwemojiSunBehindCloud = Assets.images.twemojiSunBehindCloud.svg();
  static final attachmentVisa = Assets.images.visa.svg();

  // Additional assets (images)
  static final attachmentFlutterLogo = Assets.images.flutterLogo.image();
  static final attachmentLoginDark = Assets.images.loginDark.image();
  static final attachmentLoginLight = Assets.images.loginLight.image();
  static final attachmentNotification = Assets.images.notification.image();
  static final attachmentSignUpDark = Assets.images.signUpDark.image();
  static final attachmentSignUpLight = Assets.images.signUpLight.image();

  // Logos
  static final attachmentShoplonLogo = Assets.logo.shoplon.svg();

  // Screens Assets
  static final attachmentAddReviewRate = Assets.screens.addReviewRate.image();
  static final attachmentAddresses = Assets.screens.addresses.image();
  static final attachmentCancelOrderSelectAReason = Assets.screens.cancelOrderSelectAReason.image();
  static final attachmentCart1 = Assets.screens.cart1.image();
  static final attachmentCart2 = Assets.screens.cart2.image();
  static final attachmentCart3 = Assets.screens.cart3.image();
  static final attachmentCart4 = Assets.screens.cart4.image();
  static final attachmentCart5 = Assets.screens.cart5.image();
  static final attachmentCart6 = Assets.screens.cart6.image();
  static final attachmentEditProfile = Assets.screens.editProfile.image();
  static final attachmentEnableNotification = Assets.screens.enableNotification.image();
  static final attachmentEnterVerificationCode = Assets.screens.enterVerificationCode.image();
  static final attachmentForgotPassword6 = Assets.screens.forgotPassword6.image();
  static final attachmentForgotPassword = Assets.screens.forgotPassword.image();
  static final attachmentKids = Assets.screens.kids.image();
  static final attachmentNoNotification = Assets.screens.noNotification.image();
  static final attachmentNotificationScreen = Assets.screens.notification.image();
  static final attachmentOnSales = Assets.screens.onSales.image();
  static final attachmentOrders = Assets.screens.orders.image();
  static final attachmentProductDetail = Assets.screens.productDetail.image();
  static final attachmentProfile = Assets.screens.profile.image();
  static final attachmentResetPassword = Assets.screens.resetPassword.image();
  static final attachmentSearch1 = Assets.screens.search1.image();
  static final attachmentSearch2 = Assets.screens.search2.image();
  static final attachmentSearch3 = Assets.screens.search3.image();
  static final attachmentSearch4 = Assets.screens.search4.image();
  static final attachmentSearch5 = Assets.screens.search5.image();
  static final attachmentSearch6 = Assets.screens.search6.image();
  static final attachmentSearch7 = Assets.screens.search7.image();
  static final attachmentSearch8 = Assets.screens.search8.image();
  static final attachmentShippingInformation = Assets.screens.shippingInformation.image();
  static final attachmentSizeGuide = Assets.screens.sizeGuide.image();
  static final attachmentVerificaitionCode = Assets.screens.verificaitionCode.image();
  static final attachmentNotificationSetting = Assets.screens.notificationSetting.image();
  static final attachmentReviews = Assets.screens.reviews.image();

  // Additional Icons from the List
  static final accessories = Assets.icons.accessories.svg();
  static final address = Assets.icons.address.svg();
  static final arrowDown = Assets.icons.arrowDown.svg();
  static final arrowLeft = Assets.icons.arrowLeft.svg();
  static final arrowRight = Assets.icons.arrowRight.svg();
  static final arrowUp = Assets.icons.arrowUp.svg();
  static final bag = Assets.icons.bag.svg();
  static final behance = Assets.icons.behance.svg();
  static final bookmark = Assets.icons.bookmark.svg();
  static final cvv = Assets.icons.cvv.svg();
  static final calender = Assets.icons.calender.svg();
  static final call = Assets.icons.call.svg();
  static final cameraBold = Assets.icons.cameraBold.svg();
  static final cameraAdd = Assets.icons.cameraAdd.svg();
  static final cardPattern = Assets.icons.cardPattern.svg();
  static final cash = Assets.icons.cash.svg();
  static final category = Assets.icons.category.svg();
  static final chatAdd = Assets.icons.chatAdd.svg();
  static final chat = Assets.icons.chat.svg();
  static final child = Assets.icons.child.svg();
  static final clock = Assets.icons.clock.svg();
  static final closeCircle = Assets.icons.closeCircle.svg();
  static final close = Assets.icons.close.svg();
  static final coupon = Assets.icons.coupon.svg();
  static final dangerCircle = Assets.icons.dangerCircle.svg();
  static final delete = Assets.icons.delete.svg();
  static final delivery = Assets.icons.delivery.svg();
  static final discount = Assets.icons.discount.svg();
  static final discountTag = Assets.icons.discountTag.svg();
  static final dislike = Assets.icons.dislike.svg();
  static final dotsH = Assets.icons.dotsH.svg();
  static final dotsV = Assets.icons.dotsV.svg();
  static final doublecheck = Assets.icons.doublecheck.svg();
  static final dribbble = Assets.icons.dribbble.svg();
  static final editSquare = Assets.icons.editSquare.svg();
  static final editBold = Assets.icons.editBold.svg();
  static final emoji = Assets.icons.emoji.svg();
  static final faq = Assets.icons.faq.svg();
  static final faceId = Assets.icons.faceId.svg();
  static final facebook = Assets.icons.facebook.svg();
  static final filter = Assets.icons.filter.svg();
  static final fingerprint = Assets.icons.fingerprint.svg();
  static final flashlight = Assets.icons.flashlight.svg();
  static final gift = Assets.icons.gift.svg();
  static final help = Assets.icons.help.svg();
  static final image = Assets.icons.image.svg();
  static final instagram = Assets.icons.instagram.svg();
  static final language = Assets.icons.language.svg();
  static final like = Assets.icons.like.svg();
  static final link = Assets.icons.link.svg();
  static final linkedin = Assets.icons.linkedin.svg();
  static final loading = Assets.icons.loading.svg();
  static final location = Assets.icons.location.svg();
  static final lock = Assets.icons.lock.svg();
  static final logout = Assets.icons.logout.svg();
  static final manWoman = Assets.icons.manWoman.svg();
  static final man = Assets.icons.man.svg();
  static final message = Assets.icons.message.svg();
  static final minus = Assets.icons.minus.svg();
  static final mylocation = Assets.icons.mylocation.svg();
  static final newcard = Assets.icons.newcard.svg();
  static final notification = Assets.icons.notification.svg();
  static final order = Assets.icons.order.svg();
  static final payonline = Assets.icons.payonline.svg();
  static final plus1 = Assets.icons.plus1.svg();
  static final preferences = Assets.icons.preferences.svg();
  static final product = Assets.icons.product.svg();
  static final profile = Assets.icons.profile.svg();
  static final returns = Assets.icons.returns.svg();
  static final sale = Assets.icons.sale.svg();
  static final scan = Assets.icons.scan.svg();
  static final search = Assets.icons.search.svg();
  static final send = Assets.icons.send.svg();
  static final setting = Assets.icons.setting.svg();
  static final share = Assets.icons.share.svg();
  static final shop = Assets.icons.shop.svg();
  static final show = Assets.icons.show.svg();
  static final singlecheck = Assets.icons.singlecheck.svg();
  static final sizeguid = Assets.icons.sizeguid.svg();
  static final sort = Assets.icons.sort.svg();
  static final standard = Assets.icons.standard.svg();
  static final starBold = Assets.icons.starBold.svg();
  static final star = Assets.icons.star.svg();
  static final starFilled = Assets.icons.starFilled.svg();
  static final stores = Assets.icons.stores.svg();
  static final trackorder = Assets.icons.trackorder.svg();
  static final wallet = Assets.icons.wallet.svg();
  static final wishlist = Assets.icons.wishlist.svg();
  static final woman = Assets.icons.woman.svg();
  static final bagFull = Assets.icons.bagFull.svg();
  static final card = Assets.icons.card.svg();
  static final diamond = Assets.icons.diamond.svg();
  static final dot = Assets.icons.dot.svg();
  static final info = Assets.icons.info.svg();
  static final miniDown = Assets.icons.miniDown.svg();
  static final miniLeft = Assets.icons.miniLeft.svg();
  static final miniRight = Assets.icons.miniRight.svg();
  static final miniTop = Assets.icons.miniTop.svg();
  static final twitter = Assets.icons.twitter.svg();
  static final worldMap = Assets.icons.worldMap.svg();
}