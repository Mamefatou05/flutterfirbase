import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavefirebase/app/modules/home/views/qr_view.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/home_controller.dart';
import 'home_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshData();
        },
        child: Column(
          children: [
            Obx(() => WaveHeader(
              title: controller.currentUser.value?.nomComplet ?? 'Mon compte',
              subtitle: controller.isBalanceVisible.value
                  ? '${controller.currentUser.value?.balance ?? 0} F'
                  : '****** F',
              showBackButton: false,
              trailing: Row(
                children: [
                  IconButton(
                    icon: Icon(
                        controller.isBalanceVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off
                    ),
                    onPressed: controller.toggleBalanceVisibility,
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () => Get.to(() => QRScreen()),
                  ),
                ],
              ),
            )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const HomeTab();
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomFooter(currentRoute: 'home'),
    );
  }
}