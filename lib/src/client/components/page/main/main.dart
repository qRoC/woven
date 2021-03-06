@HtmlImport('main.html')

library client.components.page.app;

import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:core_elements/core_dropdown.dart';
import 'package:core_elements/core_menu.dart';
import 'package:core_elements/core_item.dart';
import 'package:core_elements/communication_icons.dart';
import 'package:core_elements/core_dropdown.dart';

import 'package:woven/src/client/app.dart';
import 'package:woven/src/client/components/channel_info/channel_info.dart';
import 'package:woven/src/client/components/community_list/community_list.dart';
import 'package:woven/src/client/components/people_list/people_list.dart';
import 'package:woven/src/client/components/user_picture/user_picture.dart';
import 'package:woven/src/client/components/chat_view/chat_view.dart';
import 'package:woven/src/client/components/inbox_list/inbox_list.dart';
import 'package:woven/src/client/components/add_stuff/add_stuff.dart';
import 'package:woven/src/client/components/page/home/home.dart';
import 'package:woven/src/client/components/add_stuff/add_stuff.dart';
import 'package:woven/src/client/components/widgets/dropdown/dropdown.dart';
import 'package:woven/src/client/components/widgets/custom_icons/custom_icons.dart';

@CustomTag('x-main')
class Main extends PolymerElement with Observable {
  @published App app;
  @observable var responsiveWidth = "900px";

  List<StreamSubscription> subscriptions = [];

  static Element get mainElement =>
      document.querySelector('woven-app').shadowRoot.querySelector('x-main');

  static List<Element> get dropdowns =>
      mainElement.shadowRoot.querySelectorAll('core-dropdown');

  static XDropdown get userMenu =>
      mainElement.shadowRoot.querySelector('.user-menu');

  toggle(Event e) {
    HtmlElement target = e.target;
    dropdowns.forEach((CoreDropdown e) => e.close());
    var dropdown = target.querySelector('core-dropdown') as CoreDropdown;
    if (dropdown != null) dropdown.toggle();
  }

  Main.created() : super.created() {}

  void switchPage(Event e, var detail, Element target) {
    app.router.switchPage(target.dataset['url']);
    Timer.run(() => togglePanel());
  }

  void scrollToTop() {
    app.scroller.scrollTop = 0;
  }

  void goBack(Event e, var detail, Element target) {
    // TODO: Clean this up.
    if (app.router.previousPage == 'lobby') app.router.dispatch(
        url: (app.community != null ? '/${app.community.alias}' : '/'));
    if (app.router.previousPage == 'feed') app.router.dispatch(
        url:
            (app.community != null ? '/${app.community.alias}/feed' : '/feed'));
    if (app.router.previousPage == 'events') app.router.dispatch(
        url: (app.community != null
            ? '/${app.community.alias}/events'
            : '/events'));
    (app.community != null)
        ? app.router.selectedPage = app.router.previousPage
        : app.router.selectedPage = 'channels';
  }

  signInWithFacebook() => app.signInWithFacebook();

  signOut() => app.signOut();

  // Toggle the drawer panel.
  togglePanel() {
//    DivElement panel = this.shadowRoot.querySelector('.left');
//    panel.classes.add('hide');
  }

  // Toggle the Add Stuff dialog.
  toggleAddStuff() {
    if (app.user == null) {
      toggleSignIn();
      return;
    }

    if (app.community == null) {
      app.showMessage('Please go to a channel first.', 'important');
      return;
    }

    AddStuff addStuff = this.shadowRoot.querySelector('add-stuff');
    addStuff.toggleOverlay();
  }

  // Toggle the sign in dialog.
  toggleSignIn() {
    app.toggleSignIn();
  }

  toggleUserMenu(Event e) {
    print('toggleUserMenu: ${e.target}');
    e.preventDefault();
    e.stopPropagation();
    userMenu.open();
  }

  toggleChannelInfo() {
    ChannelInfo channelInfo = this.shadowRoot.querySelector('channel-info');
    channelInfo.style.backgroundColor = 'red';
    channelInfo.toggleOverlay();
  }

  changeTitle() {
    HtmlElement el;
    el = this.shadowRoot.querySelector('#page-title');
    if (el != null) {
      el.style.opacity = '0';
      new Timer(new Duration(milliseconds: 750), () {
        el.style.opacity = '1';
        el.text = (app.pageTitle != null) ? '${app.pageTitle}' : '';
      });
    } else {
      if (app.debugMode) print('DEBUG: pageTitle is NULL!');
    }
  }

  attached() async {
//    new Timer(new Duration(seconds: 1), () {
//      window.scrollTo(0, 1);
//    });

//    print('''
//    ${mainElement.shadowRoot.querySelector('.side-panel .close')}
//    ''');

    //querySelector('.main').text = 'Your Dart app is running.';
    final Element toolbar = mainElement.shadowRoot.querySelector('.toolbar');
    final Element sidePanel = mainElement.shadowRoot.querySelector('.left');
    final Element closeButton =
        mainElement.shadowRoot.querySelector('.left #close-button');
    final Element menuButton =
        mainElement.shadowRoot.querySelector('.toolbar .icon.menu');
    final Element scrim = mainElement.shadowRoot.querySelector('.scrim');
    final Element mainDiv = mainElement.shadowRoot.querySelector('.main');

    hide() {
//      if (sidePanel.classes.contains('hide')) {
      toolbar.classes.add('hide');
//      }
    }

    show() {
      toolbar.classes.remove('hide');
    }

    var oldY = 0;

//    if (app.isMobile) {
//      document.onScroll.listen((_) {
//        print('debug: scrolled');
//        var newY = document.body.scrollTop;
//        if ((oldY - newY).abs() > 30) {
//          if (oldY < newY) {
//            hide();
//          } else {
//            show();
//          }
//        }
//        oldY = newY;
//      });
//    }

    // TODO: Is adding class on every listen slow? Maybe hold a local var?
//    closeButton.onClick.listen((e) {
//      sidePanel.classes.add('hide');
////      scrim.classes.removeAll(['show']);
////      mainDiv.classes.remove('noscroll');
//    });

    document.body.onClick.listen((e) {
      sidePanel.classes.remove('show');
    });

    menuButton.onClick.listen((e) {
      e.stopPropagation();
      if (sidePanel.classes.contains('show')) {
        sidePanel.classes.remove('show');
      } else {
        sidePanel.classes.add('show');
      }

//    scrim.classes.addAll(['show']);
//      mainDiv.classes.add('noscroll');
    });

    changeTitle();

//    app.router.onDispatch.listen((page) {
//      changeTitle();
//    });
  }
}
