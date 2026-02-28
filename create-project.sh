#!/bin/bash

# FocusLens Xcode Project Creator
# This script creates a complete Xcode project for FocusLens

set -e

echo "🎯 Creating FocusLens Xcode Project..."
echo ""

PROJECT_DIR="/Users/lukezhu/Documents/hackathon/FocusLens-Swift"
cd "$PROJECT_DIR"

# Create project structure
mkdir -p FocusLens.xcodeproj

# Create project.pbxproj file
cat > FocusLens.xcodeproj/project.pbxproj << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1000001000000000000001 /* FocusLensApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000002000000000000001 /* FocusLensApp.swift */; };
		A1000003000000000000001 /* OverlayWindow.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000004000000000000001 /* OverlayWindow.swift */; };
		A1000005000000000000001 /* OverlayViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000006000000000000001 /* OverlayViewModel.swift */; };
		A1000007000000000000001 /* OverlayContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000008000000000000001 /* OverlayContentView.swift */; };
		A1000009000000000000001 /* ControlBarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000010000000000000001 /* ControlBarView.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A1000000000000000000001 /* FocusLens.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = FocusLens.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A1000002000000000000001 /* FocusLensApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FocusLensApp.swift; sourceTree = "<group>"; };
		A1000004000000000000001 /* OverlayWindow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OverlayWindow.swift; sourceTree = "<group>"; };
		A1000006000000000000001 /* OverlayViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OverlayViewModel.swift; sourceTree = "<group>"; };
		A1000008000000000000001 /* OverlayContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OverlayContentView.swift; sourceTree = "<group>"; };
		A1000010000000000000001 /* ControlBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ControlBarView.swift; sourceTree = "<group>"; };
		A1000011000000000000001 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		A1000012000000000000001 /* FocusLens.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = FocusLens.entitlements; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1999999000000000000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1999998000000000000001 = {
			isa = PBXGroup;
			children = (
				A1999997000000000000001 /* FocusLens */,
				A1999996000000000000001 /* Products */,
			);
			sourceTree = "<group>";
		};
		A1999997000000000000001 /* FocusLens */ = {
			isa = PBXGroup;
			children = (
				A1000002000000000000001 /* FocusLensApp.swift */,
				A1000004000000000000001 /* OverlayWindow.swift */,
				A1000006000000000000001 /* OverlayViewModel.swift */,
				A1000008000000000000001 /* OverlayContentView.swift */,
				A1000010000000000000001 /* ControlBarView.swift */,
				A1000011000000000000001 /* Info.plist */,
				A1000012000000000000001 /* FocusLens.entitlements */,
			);
			path = FocusLens;
			sourceTree = "<group>";
		};
		A1999996000000000000001 /* Products */ = {
			isa = PBXGroup;
			children = (
				A1000000000000000000001 /* FocusLens.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A1999995000000000000001 /* FocusLens */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A1999994000000000000001 /* Build configuration list for PBXNativeTarget "FocusLens" */;
			buildPhases = (
				A1999993000000000000001 /* Sources */,
				A1999999000000000000001 /* Frameworks */,
				A1999992000000000000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = FocusLens;
			productName = FocusLens;
			productReference = A1000000000000000000001 /* FocusLens.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1999991000000000000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					A1999995000000000000001 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = A1999990000000000000001 /* Build configuration list for PBXProject "FocusLens" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A1999998000000000000001;
			productRefGroup = A1999996000000000000001 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1999995000000000000001 /* FocusLens */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A1999992000000000000001 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A1999993000000000000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1000001000000000000001 /* FocusLensApp.swift in Sources */,
				A1000003000000000000001 /* OverlayWindow.swift in Sources */,
				A1000005000000000000001 /* OverlayViewModel.swift in Sources */,
				A1000007000000000000001 /* OverlayContentView.swift in Sources */,
				A1000009000000000000001 /* ControlBarView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A1999989000000000000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		A1999988000000000000001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		A1999987000000000000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = FocusLens/FocusLens.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = NO;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = FocusLens/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_LSUIElement = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.focuslens.FocusLens;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		A1999986000000000000001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = FocusLens/FocusLens.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = NO;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = FocusLens/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_LSUIElement = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.focuslens.FocusLens;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1999990000000000000001 /* Build configuration list for PBXProject "FocusLens" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1999989000000000000001 /* Debug */,
				A1999988000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A1999994000000000000001 /* Build configuration list for PBXNativeTarget "FocusLens" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1999987000000000000001 /* Debug */,
				A1999986000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = A1999991000000000000001 /* Project object */;
}
EOF

echo "✅ Created project.pbxproj"

# Create workspace settings
mkdir -p FocusLens.xcodeproj/project.xcworkspace
cat > FocusLens.xcodeproj/project.xcworkspace/contents.xcworkspacedata << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
EOF

echo "✅ Created workspace settings"

# Create xcshareddata
mkdir -p FocusLens.xcodeproj/project.xcworkspace/xcshareddata
cat > FocusLens.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
EOF

echo "✅ Created shared data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Xcode Project Created Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Project location: $PROJECT_DIR/FocusLens.xcodeproj"
echo ""
echo "🚀 Next steps:"
echo "   1. Open the project: open FocusLens.xcodeproj"
echo "   2. Press Cmd+B to build"
echo "   3. Press Cmd+R to run"
echo ""
echo "✅ All source files are already included!"
echo "✅ Entitlements configured (App Sandbox disabled)"
echo "✅ Minimum deployment target: macOS 13.0"
echo ""
