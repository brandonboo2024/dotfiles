-- This card's UCM profiles make Speaker and Headphones mutually exclusive.
-- HDMI keeps both profiles "available" even with the headphone jack unplugged,
-- so ordinary saved-profile selection cannot follow the jack reliably.
local cutils = require ("common-utils")
local card = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
local speaker_profile = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
local headphone_profile = "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"

SimpleEventHook {
  name = "device/prometheus-output-profile",
  before = "device/find-stored-profile",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-profile" },
      Constraint { "device.name", "=", card },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    local desired = nil
    for p in device:iterate_params ("EnumRoute") do
      local route = cutils.parseParam (p, "EnumRoute")
      if route and route.name == "[Out] Headphones" then
        if route.available == "yes" then
          desired = headphone_profile
        elseif route.available == "no" then
          desired = speaker_profile
        end
        break
      end
    end
    if not desired then return end

    -- These exact profiles retain the same Mic1 and Mic2 inputs. Leave other
    -- cards, unknown jack states and changed UCM layouts to the stock policy.
    for p in device:iterate_params ("EnumProfile") do
      local profile = cutils.parseParam (p, "EnumProfile")
      if profile and profile.name == desired and profile.available ~= "no" then
        event:set_data ("selected-profile", profile)
        return
      end
    end
  end,
}:register ()

SimpleEventHook {
  name = "device/prometheus-jack-changed",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "device-params-changed" },
      Constraint { "event.subject.param-id", "=", "EnumRoute" },
      Constraint { "device.name", "=", card },
    },
  },
  execute = function (event)
    event:get_source ():call ("push-event", "select-profile",
      event:get_subject (), nil)
  end,
}:register ()
