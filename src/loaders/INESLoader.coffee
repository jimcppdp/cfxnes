AbstractLoader = require "./AbstractLoader"
Types          = require "../Types"

Mirroring      = Types.Mirroring
TVSystem       = Types.TVSystem

INES_SIGNATURE = [ 0x4E, 0x45, 0x53, 0x1A ] # "NES^Z"

###########################################################
# Loader for the iNES ROM format
###########################################################

class INESLoader extends AbstractLoader

    @supportsInput: (reader) ->
        @containsSignature reader, INES_SIGNATURE

    readCartridge: ->
        @readHeader()  #  16 B [$0000-$000F]
        @readTrainer() # 512 B (optional)
        @readROM()     #  16KB x number of units
        @readVROM()    #   8KB x number of units
        @createSRAM()  #   8KB x number of units

    ###########################################################
    # Header reading
    ###########################################################

    readHeader: ->
        @checkSignature INES_SIGNATURE # 4B [$00-$03]
        @readROMSize()                 # 1B [$04]
        @readVROMSize()                # 1B [$05]
        @readControlBytes()            # 2B [$06,$07]
        @readSRAMSize()                # 1B [$08]
        @readFlags9()                  # 1B [$09]
        @readFlags10()                 # 1B [$0A]
        @readRestOfHeader()            # 5B [$0B-$0F]

    readROMSize: ->
        @cartridge.romSize  = @readByte() * 0x4000 # N x 16KB

    readVROMSize: ->
        @cartridge.vromSize = @readByte() * 0x2000 # N x 8KB
        @cartridge.hasVRAM = @cartridge.vromSize == 0

    readControlBytes: ->
        controlByte1 = @readByte()
        controlByte2 = @readByte()

        if controlByte1 & 0x08
            @cartridge.mirroring = Mirroring.FOUR_SCREEN
        else if controlByte1 & 0x01
            @cartridge.mirroring = Mirroring.VERTICAL
        else
            @cartridge.mirroring = Mirroring.HORIZONTAL

        @cartridge.hasBattery = (controlByte1 & 0x02) != 0
        @cartridge.hasTrainer = (controlByte1 & 0x04) != 0
        @cartridge.hasVsUnisistem = (controlByte2 & 0x01) != 0
        @cartridge.hasPlayChoice = (controlByte2 & 0x02) != 0
        @cartridge.mapperId = (controlByte2 & 0xF0) | (controlByte1 >>> 4)
        
    readSRAMSize: ->
        unitsCount = Math.max 1, @readByte() # At least 1 unit (compatibility purposes)
        @cartridge.sramSize = unitsCount * 0x2000 # N x 8KB

    readFlags9: ->
        flags = @readByte()
        @cartridge.tvSystem = if flags & 0x01 then TVSystem.PAL else TVSystem.NTSC

    readFlags10: ->
        flags = @readByte()
        @cartridge.hasSRAM = (flags & 0x10) == 0
        @cartridge.hasBUSConflicts = (flags & 0x20) != 0

    readRestOfHeader: ->
        @readArray 5

    ###########################################################
    # Data reading
    ###########################################################

    readTrainer: ->
        @cartridge.trainer = @readArray 0x200 if @cartridge.hasTrainer # 512B

    readROM: ->
        @cartridge.rom = @readArray @cartridge.romSize

    readVROM: ->
        @cartridge.vrom = @readArray @cartridge.vromSize

    createSRAM: ->
        @cartridge.sram = (0 for [0...@cartridge.sramSize])

module.exports = INESLoader
