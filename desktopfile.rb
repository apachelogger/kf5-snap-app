# frozen_string_literal: true
#
# Copyright (C) 2017-2918 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

class Desktopfile
  attr_reader :path
  attr_reader :lines

  # NB: the data needs to be read here. we move out of the context of the
  #   temporary file after construction!!!
  def initialize(path)
    @path = path
    @lines = File.read(path).split($/)
  end

  def dbus?
    lines.any? do |x|
      x.start_with?('X-DBUS-ServiceName=') || x.match?(/X-DBUS-StartupType=(Multi|Unique)/)
    end
  end

  def service_name
    return nil unless dbus?
    dbus_line = lines.find { |x| x.start_with?('X-DBUS-ServiceName=') }
    return dbus_line.split('=', 2)[-1] if dbus_line
    # NB: technically the name is assumed to be org.kde.binaryname. However,
    #   due to wayland the desktop file should be named thusly anyway.
    #   Technically wayland may also be set programatically though, so
    #   this assumption may not always be true and we indeed need to resolve
    #   org.kde.binaryname, which is tricky because that entails parsing Exec=.
    name = File.basename(path, '.desktop')
    raise unless name.start_with?('org.kde.')
    name
  end
end
