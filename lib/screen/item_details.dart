import 'package:flutter/material.dart';
import 'package:msu_app/model/ItemSet.dart';
import '../model/item_model.dart';
import '../service/item_service.dart';
import '../service/Item_set.dart';
import '../theme/app_colors.dart';

class ItemDialogScreen extends StatefulWidget {
  final String itemName;
  final String imageUrl;
  final String itemAccessKey;
  final int? itemID;

  const ItemDialogScreen({
    super.key,
    required this.itemName,
    required this.imageUrl,
    required this.itemAccessKey,
    required this.itemID,
  });

  @override
  State<ItemDialogScreen> createState() => _ItemDialogScreenState();
}

class _ItemDialogScreenState extends State<ItemDialogScreen> {
  ItemDetail? item;
  ItemSet? itemSet;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final result = await ItemService.fetchItemDetail(widget.itemAccessKey);

    await Future.delayed(const Duration(seconds: 1));

    final setResult = (widget.itemID != null && widget.itemID! > 0)
        ? await ItemSetService.fetchItemSet(widget.itemID)
        : null;

    setState(() {
      item = result;
      itemSet = setResult;
      isLoading = false;
    });
  }

  // --------------------- 🔹 STAT ROW (complex) ---------------------
  Widget _buildStatRow(String name, dynamic stat) {
    if (stat == null) return const SizedBox();

    final base = stat.base ?? 0;
    final extra = stat.extra ?? 0;
    final enhance = stat.enhance ?? 0;
    final total = stat.total ?? 0;

    if (total == 0 && base == 0 && extra == 0 && enhance == 0) {
      return const SizedBox();
    }

    final displayBase = total - extra - enhance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$name:",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppColors.text),
              children: [
                TextSpan(
                  text: "$total ",
                  style: const TextStyle(
                    color: AppColors.iconPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: "(",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextSpan(
                  text: "$displayBase",
                  style: const TextStyle(color: AppColors.text),
                ),
                if (extra != 0) ...[
                  const TextSpan(text: " + "),
                  TextSpan(
                    text: "$extra",
                    style:
                    const TextStyle(color: AppColors.buttonPrimaryLight),
                  )
                ],
                if (enhance != 0) ...[
                  const TextSpan(text: " + "),
                  TextSpan(
                    text: "$enhance",
                    style: const TextStyle(color: AppColors.iconSecondary),
                  ),
                ],
                const TextSpan(text: ")"),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --------------------- 🔹 Simple Stat Row ---------------------
  Widget _buildSimpleStatRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$name:",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.iconPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------- 🔹 Item Set Section ---------------------
  Widget _buildItemSetSection(ItemSet set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "⭐ ${set.setName} Set",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.iconPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: AppColors.border),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: set.pieces.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, i) {
            final p = set.pieces[i];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  p.imageUrl.isNotEmpty
                      ? Image.network(
                    p.imageUrl,
                    width: 40,
                    height: 40,
                  )
                      : const Icon(Icons.image_not_supported,
                      size: 40, color: AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(
                    p.representName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    p.typeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        const Text(
          "Hiệu ứng Set:",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        ...set.effects.map((e) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.iconPrimary.withOpacity(.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.equipCount} Mảnh",
                  style: const TextStyle(
                      color: AppColors.iconPrimary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...e.desc.map((d) => Text(
                  "• $d",
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 13),
                )),
              ],
            ),
          );
        })
      ],
    );
  }

  // --------------------- 🔹 Close Button ---------------------
  Widget _buildCloseButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded),
            SizedBox(width: 8),
            Text("ĐÓNG CHI TIẾT",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // --------------------- 🔹 MAIN UI ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: 380,
          constraints: const BoxConstraints(maxHeight: 680),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.iconPrimary, width: 2),
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardGradient,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.itemName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.iconPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                    )
                  ],
                ),
              ),

              // BODY
              Expanded(
                child: isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.iconPrimary))
                    : item == null
                    ? const Center(
                  child: Text(
                    "Không thể tải dữ liệu.",
                    style: TextStyle(color: AppColors.text),
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // IMAGE
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          widget.imageUrl,
                          width: 80,
                          height: 80,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.error,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // STATS
                      const Text(
                        "Chỉ số cơ bản:",
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const Divider(color: AppColors.border),

                      _buildStatRow("STR", item!.stats.str),
                      _buildStatRow("DEX", item!.stats.dex),
                      _buildStatRow("INT", item!.stats.int),
                      _buildStatRow("LUK", item!.stats.luk),
                      _buildStatRow("ATT", item!.stats.pad),
                      _buildStatRow("Magic ATT", item!.stats.mad),
                      _buildStatRow("DEF", item!.stats.pdd),
                      _buildStatRow("Max HP", item!.stats.maxHp),

                      if (item!.common.maxStarforce != null)
                        _buildSimpleStatRow("Max Starforce",
                            item!.common.maxStarforce.toString()),

                      const SizedBox(height: 16),

                      Text(
                        item!.common.desc ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 16),

                      if (itemSet != null)
                        _buildItemSetSection(itemSet!)
                    ],
                  ),
                ),
              ),

              _buildCloseButton()
            ],
          ),
        ),
      ),
    );
  }
}
