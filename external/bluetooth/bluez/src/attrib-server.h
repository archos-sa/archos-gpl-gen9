/*
 *
 *  BlueZ - Bluetooth protocol stack for Linux
 *
 *  Copyright (C) 2010  Nokia Corporation
 *  Copyright (C) 2010  Marcel Holtmann <marcel@holtmann.org>
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

typedef void (*GAttribIndFunc) (guint8 status, struct btd_adapter *adapter,
				struct btd_device *device, gpointer user_data);

uint16_t attrib_db_find_avail(struct btd_adapter *adapter, bt_uuid_t *svc_uuid,
							uint16_t nitems);
struct attribute *attrib_db_add(struct btd_adapter *adapter, uint16_t handle,
				bt_uuid_t *uuid, int read_reqs, int write_reqs,
				const uint8_t *value, int len);
int attrib_db_update(struct btd_adapter *adapter, uint16_t handle,
					bt_uuid_t *uuid, const uint8_t *value,
					int len, struct attribute **attr);
int attrib_db_del(struct btd_adapter *adapter, uint16_t handle);
int attrib_gap_set(struct btd_adapter *adapter, uint16_t uuid,
						const uint8_t *value, int len);
uint32_t attrib_create_sdp(struct btd_adapter *adapter, uint16_t handle,
							const char *name);
void attrib_free_sdp(uint32_t sdp_handle);
guint attrib_channel_attach(GAttrib *attrib);
gboolean attrib_channel_detach(GAttrib *attrib, guint id);
guint queue_notification(struct btd_adapter *adapter, bdaddr_t *addr,
			 uint16_t handle, uint16_t handle_ccc,
			 void *data, size_t len);
guint queue_indication(struct btd_adapter *adapter, bdaddr_t *addr,
		       uint16_t handle, uint16_t handle_ccc,
		       void *data, size_t len,
		       GAttribIndFunc func, gpointer user_data);
int attrib_invalidate_attributes(struct btd_adapter *adapter);