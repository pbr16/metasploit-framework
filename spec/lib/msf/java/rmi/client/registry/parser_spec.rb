# -*- coding:binary -*-
require 'spec_helper'

require 'rex/java/serialization'
require 'rex/proto/rmi'
require 'msf/java/rmi/client'

describe Msf::Java::Rmi::Client::Registry::Parser do
  subject(:mod) do
    mod = ::Msf::Exploit.new
    mod.extend ::Msf::Java::Rmi::Client
    mod.send(:initialize)
    mod
  end

  let(:lookup_return) do
    raw = "\xac\xed\x00\x05\x77\x0f\x01\x38\x7c\xdd\xc3\x00\x00\x01\x4c\x2d" +
      "\x86\x47\x4c\x80\x65\x73\x72\x00\x2e\x6a\x61\x76\x61\x78\x2e\x6d" +
      "\x61\x6e\x61\x67\x65\x6d\x65\x6e\x74\x2e\x72\x65\x6d\x6f\x74\x65" +
      "\x2e\x72\x6d\x69\x2e\x52\x4d\x49\x53\x65\x72\x76\x65\x72\x49\x6d" +
      "\x70\x6c\x5f\x53\x74\x75\x62\x00\x00\x00\x00\x00\x00\x00\x02\x02" +
      "\x00\x00\x70\x78\x72\x00\x1a\x6a\x61\x76\x61\x2e\x72\x6d\x69\x2e" +
      "\x73\x65\x72\x76\x65\x72\x2e\x52\x65\x6d\x6f\x74\x65\x53\x74\x75" +
      "\x62\xe9\xfe\xdc\xc9\x8b\xe1\x65\x1a\x02\x00\x00\x70\x78\x72\x00" +
      "\x1c\x6a\x61\x76\x61\x2e\x72\x6d\x69\x2e\x73\x65\x72\x76\x65\x72" +
      "\x2e\x52\x65\x6d\x6f\x74\x65\x4f\x62\x6a\x65\x63\x74\xd3\x61\xb4" +
      "\x91\x0c\x61\x33\x1e\x03\x00\x00\x70\x78\x70\x77\x37\x00\x0a\x55" +
      "\x6e\x69\x63\x61\x73\x74\x52\x65\x66\x00\x0e\x31\x37\x32\x2e\x31" +
      "\x36\x2e\x31\x35\x38\x2e\x31\x33\x32\x00\x00\x11\x96\x8a\xd0\x5a" +
      "\x9e\xa1\xeb\x94\x3e\x38\x7c\xdd\xc3\x00\x00\x01\x4c\x2d\x86\x47" +
      "\x4c\x80\x01\x01\x78"
    io = StringIO.new(raw, 'rb')
    rv = Rex::Proto::Rmi::Model::ReturnValue.new
    rv.decode(io)

    rv
  end

  let(:remote_object) { 'javax.management.remote.rmi.RMIServerImpl_Stub' }
  let(:remote_interface) do
    {
      address: '172.16.158.132',
      port: 4502,
      object_number: -8444149663951776706
    }
  end

  let(:list_return) do
    raw = "\xac\xed\x00\x05\x77\x0f\x01\x38\x7c\xdd\xc3\x00\x00\x01\x4c\x2d" +
    "\x86\x47\x4c\x80\x66\x75\x72\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2e" +
    "\x6c\x61\x6e\x67\x2e\x53\x74\x72\x69\x6e\x67\x3b\xad\xd2\x56\xe7" +
    "\xe9\x1d\x7b\x47\x02\x00\x00\x70\x78\x70\x00\x00\x00\x01\x74\x00" +
    "\x06\x6a\x6d\x78\x72\x6d\x69"

    io = StringIO.new(raw, 'rb')
    rv = Rex::Proto::Rmi::Model::ReturnValue.new
    rv.decode(io)

    rv
  end

  let(:names) { ['jmxrmi'] }

  describe "#parse_registry_lookup_endpoint" do
    it "returns the remote reference information in a Hash" do
      expect(mod.parse_registry_lookup_endpoint(lookup_return)).to be_a(Hash)
    end

    it "returns the remote address" do
      ref = mod.parse_registry_lookup_endpoint(lookup_return)
      expect(ref[:address]).to eq(remote_interface[:address])
    end

    it "returns the remote port" do
      ref = mod.parse_registry_lookup_endpoint(lookup_return)
      expect(ref[:port]).to eq(remote_interface[:port])
    end

    it "returns the remote object number" do
      ref = mod.parse_registry_lookup_endpoint(lookup_return)
      expect(ref[:object_number]).to eq(remote_interface[:object_number])
    end

    it "returns the remote object unique identifier" do
      ref = mod.parse_registry_lookup_endpoint(lookup_return)
      expect(ref[:uid]).to be_a(Rex::Proto::Rmi::Model::UniqueIdentifier)
    end
  end

  describe "#parse_registry_list" do
    it "returns the list of names" do
      expect(mod.parse_registry_list(list_return)).to eq(names)
    end
  end

end

