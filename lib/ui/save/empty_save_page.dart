import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/dimens.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc_app_template/widgets/network_image_with_loader/network_image_with_loader.dart';

class EmptySavePage extends StatelessWidget {
  const EmptySavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const Padding(
              padding: EdgeInsets.all(AppDefaults.padding * 2),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child:
                    NetworkImageWithLoader('https://i.imgur.com/mbjap7k.png'),
              ),
            ),
          ),
          Text(
            S.of(context).oops,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(S.of(context).noProductInWishlist),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding * 2),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(S.of(context).startAddingButton),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
