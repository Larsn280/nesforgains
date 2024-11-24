import 'package:flutter/material.dart';
import 'package:nesforgains/service/auth_service.dart';

class CustomNavigationMenu extends StatefulWidget {
  const CustomNavigationMenu({super.key});
  @override
  CustomNavigationMenuState createState() => CustomNavigationMenuState();
}

class CustomNavigationMenuState extends State<CustomNavigationMenu> {
  OverlayEntry? _overlayEntry;
  final Map<String, bool> _submenuOpen = {
    "nutrition": false,
    "workout": false,
    "recipe": false,
  };
  final Color subColor = Colors.blueGrey;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleSubmenu(String menuKey) {
    setState(() {
      _submenuOpen.updateAll((key, value) => key == menuKey ? !value : false);
    });
    _overlayEntry!.markNeedsBuild();
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Stack(
              children: [
                GestureDetector(
                  onTap: _removeOverlay,
                  behavior: HitTestBehavior
                      .opaque, // Ensures the whole area responds to taps
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Material(
                    color: Colors.transparent,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildMenuOption(
                            icon: Icons.home,
                            label: 'Home',
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                              _removeOverlay();
                            },
                          ),
                          buildMenuOption(
                            icon: Icons.dining,
                            label: 'Nutrition',
                            onPressed: () => _toggleSubmenu('nutrition'),
                            hasSubcategories: true,
                            isOpen: _submenuOpen['nutrition']!,
                          ),
                          if (_submenuOpen['nutrition']!)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildMenuOption(
                                  icon: Icons.calculate,
                                  label: 'Nutrition Calculator',
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/nutritionScreen');
                                    _removeOverlay();
                                  },
                                  color: subColor,
                                ),
                                buildMenuOption(
                                    icon: Icons.list,
                                    label: 'Display Nutrition',
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/displaynutritionScreen');
                                      _removeOverlay();
                                    },
                                    color: subColor),
                              ],
                            ),
                          buildMenuOption(
                            icon: Icons.bar_chart,
                            label: 'Workouts',
                            onPressed: () => _toggleSubmenu('workout'),
                            hasSubcategories: true,
                            isOpen: _submenuOpen['workout']!,
                          ),
                          if (_submenuOpen['workout']!)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildMenuOption(
                                  icon: Icons.list,
                                  label: 'Display Workouts',
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/displayworkoutScreen');
                                    _removeOverlay();
                                  },
                                  color: subColor,
                                ),
                              ],
                            ),
                          buildMenuOption(
                            icon: Icons.receipt,
                            label: 'Recipes',
                            onPressed: () => _toggleSubmenu('recipe'),
                            hasSubcategories: true,
                            isOpen: _submenuOpen['recipe']!,
                          ),
                          if (_submenuOpen['recipe']!)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildMenuOption(
                                    icon: Icons.list,
                                    label: 'Recipelist',
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/displayrecipeScreen');
                                      _removeOverlay();
                                    },
                                    color: subColor),
                              ],
                            ),
                          buildMenuOption(
                            icon: Icons.book_sharp,
                            label: 'Book of Exuses',
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/bookofexusesScreen');
                              _removeOverlay();
                            },
                          ),
                          InkWell(
                              onTap: () {
                                AuthProvider.of(context).logout();
                                _removeOverlay();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: Colors.black,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Widget buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.black,
    bool hasSubcategories = false,
    bool isOpen = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
            if (hasSubcategories)
              Icon(
                isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
        semanticLabel: 'Navigation Menu',
      ),
      onPressed: _toggleOverlay,
    );
  }
}
