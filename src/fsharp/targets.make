SOURCES := $(patsubst $(srcdir)$(tmpdir)%,$(tmpdir)%,$(patsubst %,$(srcdir)%,$(sources)))

.PHONY: install install-lib-net20 install-lib-monodroid install-lib-net40

build:
	MONO_ENV_OPTIONS=$(monoopts) $(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=$(TargetFramework) /p:MonoLibDir40=$(monogacdir40) /p:FSharpCoreBackVersion=$(FSharpCoreBackVersion)

clean:
	$(XBUILD) /p:Configuration=$(Configuration) /p:TargetFramework=$(TargetFramework) /t:Clean

# Install the library binaries in the GAC and the framework directory, 
# Install .optdata/.sigdata if they exist (they go alongside FSharp.Core)
# Install the .Targets file. The XBuild targets file gets installed into the place(s) expected for standard F# project
# files. For F# 2.0 project files this is
#     /usr/lib/mono/Microsoft F#/v4.0/Microsoft.FSharp.Targets
# For F# 3.0 project files this is
#     /usr/lib/mono/Microsoft SDKs/F#/3.0/Framework/v4.0/Microsoft.FSharp.Targets
# For F# 3.1 project files this is
#     /usr/lib/mono/xbuild/Microsoft/VisualStudio/v12.0/FSharp/Microsoft.FSharp.Targets
# For F# 4.0 project files this is
#     /usr/lib/mono/xbuild/Microsoft/VisualStudio/v14.0/FSharp/Microsoft.FSharp.Targets
# 
# Here 12.0/14.0 is 'VisualStudioVersion'. xbuild should set this to 11.0/12.0/14.0, copying MSBuild.
#
# We put the F# targets and link the SDK DLLs for all these locations
#
# We put a forwarding targets file into all three locations. We also put one in 
#     .../lib/mono/xbuild/Microsoft/VisualStudio/v12.0/FSharp/Microsoft.FSharp.Targets
# since this is the correct location, and 'xbuild' may in future start setting VisualStudioVersion to this value.
#
# Add appropriate softlinks under 
#     ...Reference Assemblies/Microsoft/FSharp/.NETCore/...
#     ...Reference Assemblies/Microsoft/FSharp/.NETFramework/...
#     ...Reference Assemblies/Microsoft/FSharp/.NETPortable/...
# And for VS2012 Profile47 compat under
#     ...Reference Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable
#
# 
install-lib:
	@echo "Installing $(ASSEMBLY)"
	@mkdir -p $(DESTDIR)$(gacdir)/$(TARGET)
	@if test "x$(DELAY_SIGN)" = "x1"; then \
	    echo "Signing $(outdir)$(ASSEMBLY) with Mono key"; \
	    sn -q -R $(outdir)$(ASSEMBLY) $(srcdir)../../../mono.snk; \
	fi
	@if test x-$(NAME) = x-FSharp.Build; then \
	    echo "Installing Microsoft.FSharp.Targets and Microsoft.Portable.FSharp.Targets into install locations matching Visual Studio"; \
	    echo " --> $(DESTDIR)$(gacdir)/$(TARGET)/"; \
	    echo " --> $(DESTDIR)$(gacdir)/Microsoft\ F#/v4.0/"; \
	    echo " --> $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.0/Framework/v4.0/"; \
	    echo " --> $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.1/Framework/v4.0/"; \
	    echo " --> $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/4.0/Framework/v4.0/"; \
	    echo " --> $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v/FSharp/"; \
	    echo " --> $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v11.0/FSharp/"; \
	    echo " --> $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v12.0/FSharp/"; \
	    echo " --> $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v14.0/FSharp/"; \
	    \
	    mkdir -p $(tmpdir); \
	    mkdir -p $(DESTDIR)$(gacdir)/Microsoft\ F#/v4.0/; \
	    mkdir -p $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.0/Framework/v4.0/; \
	    mkdir -p $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.1/Framework/v4.0/; \
	    mkdir -p $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/4.0/Framework/v4.0/; \
	    mkdir -p $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v/FSharp/; \
	    mkdir -p $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v11.0/FSharp/; \
	    mkdir -p $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v12.0/FSharp/; \
	    mkdir -p $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v14.0/FSharp/; \
	    \
	    $(INSTALL_LIB) $(outdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/$(TARGET)/; \
	    $(INSTALL_LIB) $(outdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/$(TARGET)/; \
	    \
	    echo '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' > $(tmpdir)Microsoft.FSharp.Targets; \
	    echo '    <Import Project="$(gacdir)/$(TARGET)/Microsoft.FSharp.Targets" />' >> $(tmpdir)Microsoft.FSharp.Targets; \
	    echo '</Project>' >> $(tmpdir)Microsoft.FSharp.Targets; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ F#/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.0/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.1/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/4.0/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v11.0/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v12.0/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v14.0/FSharp/; \
	    \
	    echo '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' > $(tmpdir)Microsoft.Portable.FSharp.Targets; \
	    echo '    <Import Project="$(gacdir)/$(TARGET)/Microsoft.Portable.FSharp.Targets" />' >> $(tmpdir)Microsoft.Portable.FSharp.Targets; \
		echo '</Project>' >> $(tmpdir)Microsoft.Portable.FSharp.Targets; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ F#/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.0/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/3.1/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/Microsoft\ SDKs/F#/4.0/Framework/v4.0/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v11.0/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v12.0/FSharp/; \
	    $(INSTALL_LIB) $(tmpdir)Microsoft.Portable.FSharp.Targets $(DESTDIR)$(gacdir)/xbuild/Microsoft/VisualStudio/v14.0/FSharp/; \
	    \
	    echo $(INSTALL_LIB) $(outdir)$(ASSEMBLY) $(DESTDIR)$((gacdir)/$(TARGET); \
	    $(INSTALL_LIB) $(outdir)$(ASSEMBLY) $(DESTDIR)$(gacdir)/$(TARGET); \
	    $(INSTALL_LIB) $(outdir)$(NAME).xml $(DESTDIR)$(gacdir)/$(TARGET); \
	else \
	    if test -e $(outdir)$(NAME).dll; then \
			if test x-$(PKGINSTALL) = x-yes; then \
				echo "Using gacutil to install $(outdir)$(ASSEMBLY) into GAC root $(DESTDIR)$(libdir) as package $(TARGET)"; \
				gacutil -i $(outdir)$(ASSEMBLY) -root $(DESTDIR)$(libdir) -package $(TARGET); \
			else \
				echo "Installing $(outdir)$(NAME).dll to $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/"; \
				mkdir -p $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
				$(INSTALL_LIB) $(outdir)$(NAME).dll $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			fi; \
		fi; \
	    if test -e $(outdir)$(NAME).xml; then \
			echo "Installing $(outdir)$(NAME).xml into $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/"; \
			mkdir -p $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			$(INSTALL_LIB) $(outdir)$(NAME).xml $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			if test x-$(PKGINSTALL) = x-yes; then \
				echo "Using linking to ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).xml to install $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).xml"; \
				ln -fs  ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).xml $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).xml; \
			fi; \
	    fi; \
		if test -e $(outdir)$(NAME).sigdata; then \
			echo "Installing $(outdir)$(NAME).sigdata into $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/"; \
			mkdir -p $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			$(INSTALL_LIB) $(outdir)$(NAME).sigdata $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			if test x-$(PKGINSTALL) = x-yes; then \
				echo "Using linking to ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata to install $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).sigdata"; \
				ln -fs  ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).sigdata; \
		    fi; \
	    fi; \
		if test -e $(outdir)$(NAME).optdata; then \
			echo "Installing $(outdir)$(NAME).optdata into $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/"; \
			mkdir -p $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			$(INSTALL_LIB) $(outdir)$(NAME).optdata $(DESTDIR)$(gacdir)/gac/$(NAME)/$(VERSION)__$(TOKEN)/; \
			if test x-$(PKGINSTALL) = x-yes; then \
				echo "Using linking to ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata to install $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).optdata"; \
				ln -fs ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata $(DESTDIR)$(gacdir)/$(TARGET)/$(NAME).optdata; \
		    fi; \
		fi; \
		if test x-$(NAME) = x-FSharp.Core && test x-$(REFASSEMPATH) != x-; then \
			echo "Installing FSharp.Core $(VERSION) reference assembly into install location matching Visual Studio"; \
			echo " --> $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION)"; \
			mkdir -p $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION); \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).xml $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION)/$(NAME).xml; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION)/$(NAME).sigdata; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION)/$(NAME).optdata; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).dll $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(REFASSEMPATH)/$(VERSION)/$(NAME).dll; \
		fi; \
		if test x-$(NAME) = x-FSharp.Core && test x-$(PCLPATH) != x-; then \
			echo "Installing FSharp.Core $(VERSION) reference assembly into install location matching Visual Studio"; \
			echo " --> $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION)"; \
			mkdir -p $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION); \
			ln -fs ../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).xml $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION)/$(NAME).xml; \
			ln -fs ../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION)/$(NAME).sigdata; \
			ln -fs ../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION)/$(NAME).optdata; \
			ln -fs ../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).dll $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/$(PCLPATH)/$(VERSION)/$(NAME).dll; \
		fi; \
		if test x-$(NAME)-$(TargetFramework)-$(VERSION) = x-FSharp.Core-portable47-2.3.5.0; then \
			echo "Installing FSharp.Core $(VERSION) reference assembly into install location matching Visual Studio"; \
			echo "   ../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).dll --> $(DESTDIR)$(gacdir)/Reference Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable"; \
			mkdir -p $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).xml $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable/$(NAME).xml; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).sigdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable/$(NAME).sigdata; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).optdata $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable/$(NAME).optdata; \
			ln -fs ../../../../../../gac/$(NAME)/$(VERSION)__$(TOKEN)/$(NAME).dll $(DESTDIR)$(gacdir)/Reference\ Assemblies/Microsoft/FSharp/3.0/Runtime/.NETPortable/$(NAME).dll; \
		fi; \
	fi

# Also place some .NET 4.5 libraries into .NET 4.0
install-lib-net40: 
	@if test '$(TargetFramework)' = 'net40'; then \
	  if test -e $(DESTDIR)$(gacdir)/4.0/; then \
		ln -fs ../4.5/$(ASSEMBLY) $(DESTDIR)$(gacdir)/4.0/$(ASSEMBLY); \
		if test -e $(DESTDIR)$(gacdir)/4.5/$(ASSEMBLY).config; then \
		    ln -fs ../4.5/$(ASSEMBLY).config $(DESTDIR)$(gacdir)/4.0/$(ASSEMBLY).config; \
		fi; \
		if test -e $(DESTDIR)$(gacdir)/4.5/$(NAME).sigdata; then \
		    ln -fs ../4.5/$(NAME).sigdata $(DESTDIR)$(gacdir)/4.0/$(NAME).sigdata; \
		fi; \
		if test -e $(DESTDIR)$(gacdir)/4.5/$(NAME).xml; then \
		    ln -fs ../4.5/$(NAME).xml $(DESTDIR)$(gacdir)/4.0/$(NAME).xml; \
		fi; \
		if test -e $(DESTDIR)$(gacdir)/4.5/$(NAME).optdata; then \
		    ln -fs ../4.5/$(NAME).optdata $(DESTDIR)$(gacdir)/4.0/$(NAME).optdata; \
		fi; \
	  fi \
	fi

# The binaries fsc.exe and fsi.exe only get installed for Mono 4.5 profile
# This also installs 'fsharpc' and 'fsharpi'
install-bin:
	chmod +x $(outdir)$(ASSEMBLY)
	sed -e 's,[@]DIR[@],$(gacdir)/$(TARGET),g' -e 's,[@]TOOL[@],$(ASSEMBLY),g' < $(topdir)launcher > $(outdir)$(subst fs,fsharp,$(NAME))
	chmod +x $(outdir)$(subst fs,fsharp,$(NAME))
	@mkdir -p $(DESTDIR)$(gacdir)/$(TARGET)
	@mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL_BIN) $(outdir)$(ASSEMBLY) $(DESTDIR)$(gacdir)/$(TARGET)
	$(INSTALL_BIN) $(outdir)$(subst fs,fsharp,$(NAME)) $(DESTDIR)$(bindir)


