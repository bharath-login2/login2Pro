import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/models/serviceman/serviceMandatoryFieldModel.dart';
import 'package:login2/service/service.dart';

class MandatoryServiceFieldsPage extends StatefulWidget {
  const MandatoryServiceFieldsPage({super.key});

  @override
  State<MandatoryServiceFieldsPage> createState() =>
      _MandatoryServiceFieldsPageState();
}

class _MandatoryServiceFieldsPageState
    extends State<MandatoryServiceFieldsPage> {
  static const Color _primary = Color(0xFF2a86c9);
  static const Color _primaryDark = Color(0xFF1D4ED8);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceMandatoryFieldItem> _fields = [];
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    _fetchMandatoryFields();
  }

  Future<void> _fetchMandatoryFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await HttpService.getServiceMandatoryFieldItems();
      if (mounted) {
        setState(() {
          _fields = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load mandatory fields: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAndDelete(ServiceMandatoryFieldItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              "Delete Field",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove '${item.fieldLabel}' from mandatory fields?",
          style: const TextStyle(fontSize: 14, color: _textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deletingId = item.id);

    try {
      final result = await HttpService().deleteServiceMandatoryField(
        id: item.id,
        fieldKey: item.fieldKey,
      );

      if (!mounted) return;

      if (result["status"] == true) {
        setState(() {
          _fields.removeWhere((f) => f.id == item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "${item.fieldLabel} deleted successfully",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "Failed to delete field",
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  void _openAddFieldDialog() {
    List<MandatoryFieldSelectItem> availableOptions = [];
    List<MandatoryFieldSelectItem> selectedFields = [];
    bool isLoadingOptions = true;
    String? loadError;
    bool isSubmitting = false;
    bool hasInitiatedFetch = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void fetchOptions() async {
            setDialogState(() {
              isLoadingOptions = true;
              loadError = null;
            });
            try {
              final items = await HttpService.getServiceMandatoryFieldsSelect();
              if (dialogCtx.mounted) {
                setDialogState(() {
                  availableOptions = items;
                  isLoadingOptions = false;
                });
              }
            } catch (err) {
              if (dialogCtx.mounted) {
                setDialogState(() {
                  loadError = "Failed to load fields: $err";
                  isLoadingOptions = false;
                });
              }
            }
          }

          if (!hasInitiatedFetch) {
            hasInitiatedFetch = true;
            fetchOptions();
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: _primary, size: 24),
                SizedBox(width: 8),
                Text(
                  "Add Mandatory Field",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Select Field",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textMuted,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "*",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingOptions)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Loading available fields...",
                            style: TextStyle(
                              fontSize: 14,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (loadError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loadError!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: fetchOptions,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  else if (availableOptions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: _textMuted, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "No fields available to select",
                              style:
                                  TextStyle(fontSize: 13, color: _textMuted),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: DropdownSearch<MandatoryFieldSelectItem>.multiSelection(
                        items: (filter, loadProps) {
                          if (filter.isEmpty) return availableOptions;
                          return availableOptions
                              .where((item) => item.field
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()))
                              .toList();
                        },
                        itemAsString: (item) => item.field,
                        compareFn: (item, selectedItem) =>
                            item.id == selectedItem.id,
                        selectedItems: selectedFields,
                        onChanged: (val) {
                          setDialogState(() {
                            selectedFields = val;
                          });
                        },
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Search field...",
                              hintStyle: const TextStyle(
                                  fontSize: 13, color: _textMuted),
                              prefixIcon: const Icon(Icons.search,
                                  size: 20, color: _primary),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: _borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: _primary, width: 1.5),
                              ),
                            ),
                          ),
                          onItemAdded: (selectedItems, addedItem) {
                            setDialogState(() {
                              selectedFields = selectedItems;
                            });
                          },
                          onItemRemoved: (selectedItems, removedItem) {
                            setDialogState(() {
                              selectedFields = selectedItems;
                            });
                          },
                          validationBuilder: (ctx, selectedItems) =>
                              const SizedBox.shrink(),
                        ),
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            hintText: "Select Field",
                            hintStyle: TextStyle(
                                color: _textMuted, fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        Navigator.of(dialogCtx).pop();
                      },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      color: _textMuted, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed:
                    (isSubmitting || isLoadingOptions || availableOptions.isEmpty)
                        ? null
                        : () async {
                            if (selectedFields.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please select at least one field"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                              );
                              return;
                            }

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(dialogCtx);
                            setDialogState(() => isSubmitting = true);

                            // Pass selected field names in field_key (use field values, not IDs)
                            final List<String> fieldKeys =
                                selectedFields.map((e) => e.field).toList();

                            final result = await HttpService()
                                .addServiceMandatoryFields(
                              fieldKeys: fieldKeys,
                            );

                            if (!mounted) return;

                            if (result["status"] == true) {
                              if (dialogCtx.mounted) {
                                nav.pop();
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result["message"] ??
                                        "Mandatory fields added successfully",
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              );
                              _fetchMandatoryFields();
                            } else {
                              if (dialogCtx.mounted) {
                                setDialogState(() => isSubmitting = false);
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result["message"] ??
                                        "Failed to add mandatory fields",
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Mandatory Service Fields",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 28),
                tooltip: "Add Mandatory Field",
                onPressed: _openAddFieldDialog,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: _textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _fetchMandatoryFields,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_fields.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchMandatoryFields,
        color: _primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rule_folder_outlined,
                      size: 48,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No Mandatory Fields Found",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tap the + button in the top right to add mandatory fields.",
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMandatoryFields,
      color: _primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _fields.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _fields[index];
          final bool isBeingDeleted = _deletingId == item.id;

          return Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
              title: Text(
                item.fieldLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Key: ${item.fieldKey}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ID: ${item.id}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: isBeingDeleted
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 22,
                      ),
                      tooltip: "Delete Field",
                      onPressed: () => _confirmAndDelete(item),
                    ),
            ),
          );
        },
      ),
    );
  }
}

