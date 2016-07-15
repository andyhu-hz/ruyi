all:
	cd ./3rd/skynet && $(MAKE) macosx
	cd ./3rd/lsocket && $(MAKE) LUA_INCLUDE=../skynet/3rd/lua
clean:
	cd ./3rd/skynet && $(MAKE) clean
	cd ./3rd/lsocket && $(MAKE) clean
