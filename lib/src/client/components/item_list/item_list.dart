import 'package:polymer/polymer.dart';
import 'package:firebase/firebase.dart' as db;
import 'dart:html';
import 'package:woven/src/shared/input_formatter.dart';
import 'package:woven/src/client/app.dart';
import 'package:core_elements/core_pages.dart';
import 'package:woven/config/config.dart';
import 'package:woven/src/client/view_model/main.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

/**
 * The InboxList class is for the list of inbox items, which is pulled from Firebase.
 */
@CustomTag('item-list')
class ItemList extends PolymerElement with Observable {
  @published App app;
  @published MainViewModel viewModel;

  ItemList.created() : super.created();

  InputElement get subject => $['subject'];

  void selectItem(Event e, var detail, Element target) {
    // Look in the items list for the item that matches the
    // id passed in the data-id attribute on the element.
    var item = viewModel.starredViewModel.items.firstWhere((i) => i['id'] == target.dataset['id']);

    app.selectedItem = item;
    app.selectedPage = 1;
    app.userCameFromInbox = true;

    var str = target.dataset['id'];
    var bytes = UTF8.encode(str);
    var base64 = CryptoUtils.bytesToBase64(bytes);

    app.router.dispatch(url: "/item/$base64");
  }

  toggleLike(Event e, var detail, Element target) {
    e.stopPropagation();

    if (target.classes.contains("selected")) {
      target.classes.remove("clicked");
    } else {
      target.classes.add("clicked");
    }

    viewModel.starredViewModel.toggleItemLike(target.dataset['id']);
  }

  toggleStar(Event e, var detail, Element target) {
    e.stopPropagation();

    viewModel.starredViewModel.toggleItemStar(target.dataset['id']);
  }

  formatItemDate(DateTime value) {
    return InputFormatter.formatMomentDate(value, short: true, momentsAgo: true);
  }

  formatEventDate(DateTime startDate) {
    // TODO: Bring back endDate, currently null.
    return InputFormatter.formatDate(startDate, showHappenedPrefix: true, trimPast: true);
  }

  attached() {
    print("+Starred");
    app.pageTitle = "Saved";

    // We only attach this when we have a user,
    // so this should always run.
    if (app.user != null) {
      viewModel.starredViewModel.loadStarredItemsForUser();
    }

    //CreateCommunityItemsScript();
  }

  detached() {
    print("-Starred");
  }
}
