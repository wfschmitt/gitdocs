# -*- encoding : utf-8 -*-

require 'active_record'

module Gitdocs
  class Share < ActiveRecord::Base
    # @return [Array<String>]
    def self.paths
      all.map(&:path)
    end

    # @param [#to_i] index
    #
    # @return [Share]
    def self.at(index)
      all[index.to_i]
    end

    # @param [String] path
    #
    # @return [Share]
    def self.find_by_path(path)
      where(path: File.expand_path(path)).first
    end

    # @param [String] path
    def self.create_by_path!(path)
      new(path: File.expand_path(path)).save!
    end

    # @param [Hash] updated_shares
    # @return [void]
    def self.update_all(updated_shares)
      updated_shares.each do |index, share_config|
        # Skip the share update if there is no path specified.
        next unless share_config['path'] && !share_config['path'].empty?

        # Split the remote_branch into remote and branch
        remote_branch = share_config.delete('remote_branch')
        share_config['remote_name'], share_config['branch_name'] =
          remote_branch.split('/', 2) if remote_branch

        at(index).update_attributes(share_config)
      end
    end

    # @param [Integer] id of the share to remove
    #
    # @return [true] share was deleted
    # @return [false] share does not exist
    def self.remove_by_id(id)
      find(id).destroy
      true
    rescue ActiveRecord::RecordNotFound
      false
    end

    # @param [String] path of the share to remove
    # @return [void]
    def self.remove_by_path(path)
      where(path: File.expand_path(path)).destroy_all
    end
  end
end
